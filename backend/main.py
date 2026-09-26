import os
from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from graph import build_agent_graph

app = FastAPI(title="Journey Agentic AI (Powered by Gemini 3.8 Flash)")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

agent_graph = build_agent_graph()

class DraftRequest(BaseModel):
    trip_request_id: str

@app.get("/")
async def root():
    return {"message": "Agentic AI Server is running! Go to /docs to test."}

@app.post("/api/v1/agents/generate-draft")
async def generate_draft(payload: DraftRequest):
    initial_state = {
        "trip_request_id": payload.trip_request_id,
        "trip_request": {},
        "hydrated_items": {},
        "agent_thoughts": "",
        "ai_schedule": None,
        "react_flow_nodes": [],
        "react_flow_edges": []
    }
    
    try:
        final_state = agent_graph.invoke(initial_state)
        return {
            "status": "success",
            "agent_thoughts": final_state["agent_thoughts"], 
            "data": {
                "nodes": final_state["react_flow_nodes"],
                "edges": final_state["react_flow_edges"]
            }
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)