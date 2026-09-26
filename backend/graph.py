import os
import uuid
from typing import TypedDict, List, Dict, Any, Optional
from pydantic import BaseModel, Field
from supabase import create_client, Client
from langchain_core.messages import SystemMessage, HumanMessage
from langchain_core.tools import tool
from langchain_google_genai import ChatGoogleGenerativeAI
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import create_react_agent

# --- Supabase Initialization ---
supabase: Client = create_client(
    os.getenv("SUPABASE_URL"), 
    os.getenv("SUPABASE_KEY")
)

# --- 1. THE TOOLS (The Agent's Hands) ---
@tool
def calculate_transit_time(location_a: str, location_b: str) -> dict:
    """Calculates the estimated travel time and cost between two locations."""
    # In production, replace with Google Maps Distance Matrix API
    print(f"\n[TOOL RUNNING] 🗺️ Calculating transit: {location_a} -> {location_b}...")
    return {"travel_minutes": 25, "estimated_cost_inr": 350}

@tool
def check_budget(current_total: float, max_budget: float) -> str:
    """Checks if the current itinerary total exceeds the user's maximum budget."""
    print(f"\n[TOOL RUNNING] 💰 Checking budget: Total ₹{current_total} / Max ₹{max_budget}...")
    if current_total > max_budget:
        return "OVER BUDGET. You must remove an activity or find a cheaper alternative."
    return "WITHIN BUDGET. Proceed with current plan."

# --- 2. PYDANTIC MODELS (The JSON Contract) ---
class ScheduledEvent(BaseModel):
    db_id: str = Field(description="The original UUID of the item")
    item_type: str = Field(description="'hotelNode', 'placeNode', or 'activityNode'")
    title: str = Field(description="Name of the item")
    day_number: int = Field(description="Day of the trip (1, 2, 3...)")
    start_time_24h: int = Field(description="Start time in military format (e.g., 900, 1430)")
    duration_minutes: int = Field(description="Estimated duration of the event")

class ItinerarySchedule(BaseModel):
    events: List[ScheduledEvent] = Field(description="Chronological list of all events")

# --- 3. LANGGRAPH STATE ---
class GraphState(TypedDict):
    trip_request_id: str
    trip_request: Dict[str, Any]
    hydrated_items: Dict[str, Any]
    agent_thoughts: str
    ai_schedule: Optional[ItinerarySchedule]
    react_flow_nodes: List[Dict[str, Any]]
    react_flow_edges: List[Dict[str, Any]]

# --- 4. GRAPH NODES ---
def hydrate_node(state: GraphState):
    print("\n[NODE] Step 1: Hydrating data from Supabase...")
    trip_id = state["trip_request_id"]
    trip_res = supabase.table("trip_requests").select("*").eq("id", trip_id).execute()
    trip = trip_res.data[0]
    
    hydrated = {"hotels": [], "places": [], "activities": []}
    if trip.get("selected_hotels"):
        hydrated["hotels"] = supabase.table("operator_hotels").select("id, name, contracted_rate_per_night").in_("id", trip["selected_hotels"]).execute().data
    if trip.get("selected_places"):
        hydrated["places"] = supabase.table("operator_places").select("id, name, recommended_duration_minutes, entry_fee_per_person").in_("id", trip["selected_places"]).execute().data
    if trip.get("selected_activities"):
        hydrated["activities"] = supabase.table("operator_activities").select("id, title, duration_minutes, cost_per_person").in_("id", trip["selected_activities"]).execute().data

    return {"trip_request": trip, "hydrated_items": hydrated}

def planner_agent_node(state: GraphState):
    print("\n[NODE] Step 2: Agent reasoning with tools in a ReAct Loop...")
    # Upgraded to gemini-3.8-flash for rapid tool execution
    llm = ChatGoogleGenerativeAI(model="gemini-3.5-flash-lite", temperature=0.2)
    
    trip = state["trip_request"]
    sys_prompt = f"""
    You are an AI Travel Architect. 
    The user's max budget is ₹{trip.get('per_person_budget', 0)}.
    You MUST use the `calculate_transit_time` and `check_budget` tools to optimize the route and costs. 
    Draft a chronological plan based strictly on the tool results.
    """
    
    # LangGraph's prebuilt ReAct agent handles the Think -> Act -> Observe loop
    agent_executor = create_react_agent(
        llm, 
        tools=[calculate_transit_time, check_budget], 
        prompt=sys_prompt
    )
    
    human_prompt = f"Items to schedule: {state['hydrated_items']}"
    result = agent_executor.invoke({"messages": [("user", human_prompt)]})
    
    # Extract the final text summary after tools have finished running
    final_thoughts = result["messages"][-1].content
    return {"agent_thoughts": final_thoughts}

def formatter_node(state: GraphState):
    print("\n[NODE] Step 3: Formatting thoughts into strict JSON schema...")
    # Upgraded to gemini-3.8-flash
    llm = ChatGoogleGenerativeAI(model="gemini-3.5-flash-lite", temperature=0)
    structured_llm = llm.with_structured_output(ItinerarySchedule)
    
    sys_prompt = SystemMessage(content="Extract the finalized schedule from the provided text and strictly format it into the requested JSON schema. Do not change the timeline.")
    
    # Failsafe to ensure we don't pass empty strings
    safe_thoughts = state.get("agent_thoughts", "Please format the hydrated items sequentially.")
    human_prompt = HumanMessage(content=safe_thoughts)
    
    result = structured_llm.invoke([sys_prompt, human_prompt])
    return {"ai_schedule": result}

def layout_node(state: GraphState):
    print("\n[NODE] Step 4: Building React Flow UI layout math...")
    schedule = state["ai_schedule"].events
    nodes = []
    edges = []
    
    for i, event in enumerate(schedule):
        node_id = f"mock_{uuid.uuid4().hex[:8]}"
        x_pos = event.day_number * 400
        minutes_from_midnight = (event.start_time_24h // 100) * 60 + (event.start_time_24h % 100)
        y_pos = int(minutes_from_midnight * 1.5) 
        
        nodes.append({
            "id": node_id,
            "type": event.item_type,
            "position": {"x": x_pos, "y": y_pos},
            "data": {"db_reference_id": event.db_id, "title": event.title, "day": event.day_number, "time": str(event.start_time_24h)}
        })
        
        if i > 0 and schedule[i-1].day_number == event.day_number:
            edges.append({
                "id": f"edge_{uuid.uuid4().hex[:8]}",
                "source": nodes[i-1]["id"],
                "target": node_id,
                "type": "smoothstep",
                "animated": True
            })
            
    return {"react_flow_nodes": nodes, "react_flow_edges": edges}

# --- 5. COMPILE THE GRAPH ---
def build_agent_graph():
    workflow = StateGraph(GraphState)
    workflow.add_node("hydrate", hydrate_node)
    workflow.add_node("planner", planner_agent_node)
    workflow.add_node("formatter", formatter_node)
    workflow.add_node("layout", layout_node)
    
    workflow.add_edge(START, "hydrate")
    workflow.add_edge("hydrate", "planner")
    workflow.add_edge("planner", "formatter")
    workflow.add_edge("formatter", "layout")
    workflow.add_edge("layout", END)
    
    return workflow.compile()