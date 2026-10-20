'use client';

import React, { useState, useEffect } from 'react';
import { TourGuide, GuideAssignment, Itinerary, TripRequest } from '../lib/types';
import { dbService } from '../lib/dbService';
import { 
  X, 
  UserCheck, 
  CheckCircle2, 
  Phone
} from 'lucide-react';

interface GuideAssignmentModalProps {
  isOpen: boolean;
  onClose: () => void;
  itinerary: Itinerary;
  request: TripRequest;
  onAssignmentComplete: (assignment: GuideAssignment) => void;
}

export const GuideAssignmentModal: React.FC<GuideAssignmentModalProps> = ({
  isOpen,
  onClose,
  itinerary,
  request,
  onAssignmentComplete,
}) => {
  const [guides, setGuides] = useState<TourGuide[]>([]);
  const [selectedGuideId, setSelectedGuideId] = useState<string>('');
  const [instructions, setInstructions] = useState<string>(
    'VIP clients. Meet guests at arrival gate or hotel lobby. Provide private commentary and assist with itinerary activities.'
  );
  const [existingAssignment, setExistingAssignment] = useState<GuideAssignment | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (isOpen) {
      loadData();
    }
  }, [isOpen, itinerary.id]);

  const loadData = async () => {
    const list = await dbService.getTourGuides();
    setGuides(list);
    if (list.length > 0 && !selectedGuideId) {
      setSelectedGuideId(list[0].id);
    }

    const assignment = await dbService.getGuideAssignment(itinerary.id);
    if (assignment) {
      setExistingAssignment(assignment);
      setSelectedGuideId(assignment.guide_id);
      if (assignment.instructions_for_guide) {
        setInstructions(assignment.instructions_for_guide);
      }
    }
  };

  if (!isOpen) return null;

  const handleAssignGuide = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedGuideId) return;

    setIsSubmitting(true);
    const chosenGuide = guides.find(g => g.id === selectedGuideId);

    const assignment: GuideAssignment = {
      id: existingAssignment?.id || `assign-${Date.now()}`,
      guide_id: selectedGuideId,
      itinerary_id: itinerary.id,
      operator_id: itinerary.operator_id || 'operator-1',
      assignment_status: 'confirmed',
      instructions_for_guide: instructions,
      assigned_at: new Date().toISOString(),
      guide: chosenGuide
    };

    await dbService.assignGuide(assignment);
    setIsSubmitting(false);
    onAssignmentComplete(assignment);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-overlay">
      <div className="w-full max-w-xl bg-zinc-900 border border-zinc-800 rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="p-4 border-b border-zinc-800 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <UserCheck className="w-4 h-4 text-cyan-400" />
            <div>
              <h2 className="text-xs font-bold text-white">Tour Guide Dispatch</h2>
              <p className="text-[10px] text-zinc-400">Assign a licensed guide to this finalized itinerary.</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="btn-interactive p-1 rounded text-zinc-400 hover:text-white"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content */}
        <form onSubmit={handleAssignGuide} className="flex-1 overflow-y-auto p-4 space-y-4 text-xs">
          <div className="p-2.5 rounded-lg bg-zinc-950 border border-zinc-800 flex items-center justify-between">
            <span className="text-zinc-400">Itinerary: <strong className="text-white">{request.destination}</strong></span>
            <span className="font-mono text-zinc-200">${itinerary.final_quotation_price.toLocaleString()}</span>
          </div>

          <div>
            <label className="block text-[11px] font-medium text-zinc-300 mb-2">
              Select Certified Guide (tour_guides table)
            </label>
            {guides.length === 0 ? (
              <p className="text-zinc-500 py-3">No guides in database yet. Add guides from the Guides tab.</p>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {guides.map((guide) => {
                  const isSelected = selectedGuideId === guide.id;
                  return (
                    <div
                      key={guide.id}
                      onClick={() => setSelectedGuideId(guide.id)}
                      className={`p-3 rounded-lg border cursor-pointer transition-colors ${
                        isSelected
                          ? 'bg-zinc-800 border-zinc-500'
                          : 'bg-zinc-950 border-zinc-800 hover:border-zinc-700'
                      }`}
                    >
                      <div className="flex items-center justify-between mb-1">
                        <h4 className="font-semibold text-white">{guide.first_name} {guide.last_name}</h4>
                        {isSelected && <CheckCircle2 className="w-3.5 h-3.5 text-white" />}
                      </div>
                      <p className="text-[10px] text-zinc-400 mb-1 flex items-center gap-1">
                        <Phone className="w-2.5 h-2.5" /> {guide.contact_number}
                      </p>
                      <div className="flex justify-between text-[10px] text-zinc-500 pt-1 border-t border-zinc-800/80">
                        <span>{guide.languages?.join(', ') || 'English'}</span>
                        <span className="font-mono text-zinc-300">${guide.daily_rate}/day</span>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          <div>
            <label className="block text-[11px] font-medium text-zinc-300 mb-1">
              Instructions for Guide
            </label>
            <textarea
              rows={3}
              value={instructions}
              onChange={(e) => setInstructions(e.target.value)}
              placeholder="Provide briefing notes, client preferences, and meetup location..."
              className="w-full p-2.5 bg-zinc-950 border border-zinc-800 rounded-lg text-xs text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-600"
            />
          </div>

          <div className="pt-2 border-t border-zinc-800 flex items-center justify-end gap-2">
            <button
              type="button"
              onClick={onClose}
              className="px-3 py-1.5 text-zinc-400 hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting || !selectedGuideId}
              className="px-4 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold rounded-lg disabled:opacity-50 transition-colors"
            >
              {isSubmitting ? 'Saving...' : existingAssignment ? 'Update Assignment' : 'Confirm Assignment'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
