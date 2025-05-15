using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

bounce_tracking_device := class(creative_device):

    @editable
    NPCSpawners:[]npc_spawner_device = array{}

    @editable
    MutatorZone:mutator_zone_device = mutator_zone_device{}
    
    @editable
    ClassSelector:class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    NoneClassSelector:class_and_team_selector_device = class_and_team_selector_device{}

    EliminatedEvent:event() = event(){}
    StopEvent:event() = event(){}

    OnBegin<override>()<suspends>:void=
        MutatorZone.AgentEntersEvent.Subscribe(InitMutator)
        MutatorZone.AgentExitsEvent.Subscribe(ExitMutator)
    
    InitMutator(Agent:agent):void=
        if(player[Agent]):
            ClassSelector.ChangeClass(Agent)
            for(NPCSpawner:NPCSpawners):
                NPCSpawner.Enable()

    ExitMutator(Agent:agent):void=
        if(player[Agent]):
            NoneClassSelector.ChangeClass(Agent)
            for(NPCSpawner:NPCSpawners):
                NPCSpawner.Disable()