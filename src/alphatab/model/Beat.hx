/*
 * This file is part of alphaTab.
 *
 *  alphaTab is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  alphaTab is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with alphaTab.  If not, see <http://www.gnu.org/licenses/>.
 */
package alphatab.model;

import alphatab.audio.MidiUtils;
import js.Boot;

/**
 * A beat is a single block within a bar. A beat is a combination
 * of several notes played at the same time. 
 */
class Beat 
{
    public static inline var WhammyBarMaxPosition = 60;
    public static inline var WhammyBarMaxValue = 24;
    
    
    public var previousBeat:Beat;
    public var nextBeat:Beat;
    public var index:Int;
    
    public var voice:Voice;
    public var notes:Array<Note>;
    public var minNote:Note;
    public var maxNote:Note;
    public var duration:Duration;
    
    public var isEmpty:Bool;
    
    public var automations:Array<Automation>;
    
    public function isRest():Bool 
    {
        return notes.length == 0;
    }

    // effects
    public var dots:Int;
    public var fadeIn:Bool;
    public var lyrics:Array<String>;
    public var pop:Bool;
    public var hasRasgueado:Bool;
    public var slap:Bool;
    public var tap:Bool;
    public var text:String;
    
    public var brushType:BrushType;
    public var brushDuration:Int;
    
    public var tupletDenominator:Int;
    public var tupletNumerator:Int;
    
    public var whammyBarPoints:Array<BendPoint>;
    public inline function hasWhammyBar():Bool { return whammyBarPoints.length > 0; }
    
    public var vibrato:VibratoType;
    public var chord:Chord;
    public inline function hasChord():Bool { return chord != null; }
    public var graceType:GraceType;
    public var pickStroke:PickStrokeType;
    
    public inline function isTremolo():Bool { return tremoloSpeed != null; }
    public var tremoloSpeed:Null<Duration>;
    
    /**
     * The timeline position of the voice within the current bar. (unit: midi ticks)
     */
    public var start:Int;
    
    public var dynamicValue:DynamicValue;
    
    public function new() 
    {
        whammyBarPoints = new Array<BendPoint>();
        notes = new Array<Note>();
        brushType = BrushType.None;
        vibrato = VibratoType.None;
        graceType = GraceType.None;
        pickStroke = PickStrokeType.None;
        duration = Duration.Quarter;
        tremoloSpeed = null;
        automations = new Array<Automation>();
        start = 0;        
        tupletDenominator = -1;
        tupletNumerator = -1;
        dynamicValue = DynamicValue.F;
    }
    
    public function clone() : Beat
    {
        var beat = new Beat();
        for (b in whammyBarPoints)
        {
            beat.whammyBarPoints.push(b.clone());
        }
        for (n in notes)
        {
            beat.addNote(n.clone());
        }
        beat.brushType = brushType;
        beat.vibrato = vibrato;
        beat.graceType = graceType;
        beat.pickStroke = pickStroke;
        beat.duration = duration;
        beat.tremoloSpeed = tremoloSpeed;
        for (a in automations)
        {
            beat.automations.push(a.clone());
        }
        beat.start = start;
        beat.tupletDenominator = tupletDenominator;
        beat.tupletNumerator = tupletNumerator;       
        beat.dynamicValue = dynamicValue;       
        
        return beat;    
    }
    
    public inline function hasTuplet()
    {
        return !(tupletDenominator == -1 && tupletNumerator == -1) &&
               !(tupletDenominator == 1 && tupletNumerator == 1);
    }
    
    /**
     * Calculates the time spent in this bar. (unit: midi ticks)
     */
    public function calculateDuration() : Int
    {
        var ticks = MidiUtils.durationToTicks(duration);
        if (dots == 2)
        {
            ticks = MidiUtils.applyDot(ticks, true);
        }
        else if (dots == 1)
        {
            ticks = MidiUtils.applyDot(ticks, false);
        }
        
        if (tupletDenominator > 0 && tupletNumerator >= 0)
        {
            ticks = MidiUtils.applyTuplet(ticks, tupletNumerator, tupletDenominator);
        }
        
        return ticks;
    }
    
    public function addNote(note:Note) : Void
    {
        note.beat = this;
        notes.push(note);
        
        if (minNote == null || note.realValue() < minNote.realValue())
        {
            minNote = note;
        }
        if (maxNote == null || note.realValue() > maxNote.realValue())
        {
            maxNote = note;
        }
    }
    
    public function getAutomation(type:AutomationType) : Automation
    {
        for (a in automations)
        {
            if (a.type == type)
            {
                return a;
            }
        }
        return null;
    }
    
    public function getNoteOnString(string:Int) : Note
    {
        for (n in notes)
        {
            if (n.string == string)
            {
                return n;
            }
        }
        return null;
    }
}