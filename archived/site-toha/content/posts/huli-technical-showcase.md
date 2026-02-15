---
title: "Huli: Nine Tails of Vengeance — Technical Deep Dive"
date: 2026-01-15
description: "A comprehensive technical breakdown of the combat, AI, and plugin architecture powering Huli: Nine Tails of Vengeance on Unreal Engine 5.7."
hero: ""
menu:
  sidebar:
    name: "Huli: Technical Showcase"
    identifier: huli-technical-showcase
    weight: 1
tags: ["UE5", "C++", "GAS", "AI", "Combat", "Architecture"]
categories: ["Portfolio"]
---

<div style="background:#1a1a2e; color:#e0e0e0; padding:1.5em 2em; border-radius:8px; margin-bottom:2em;">

**Role:** Lead Gameplay Engineer &nbsp;|&nbsp; **Engine:** Unreal Engine 5.7 &nbsp;|&nbsp; **Platforms:** PC, PS5, Xbox Series X

**Huli: Nine Tails of Vengeance** is a combat-driven Action RPG featuring deep melee combat, AI-coordinated enemy encounters, and a modular plugin architecture built for scalability. This page walks through the core technical systems I designed and implemented.

</div>

---

## Architecture Overview

The project is built on a **three-tier modular plugin architecture** that enforces clean dependency boundaries and supports independent iteration across teams.

```
┌─────────────────────────────────────────────────────────────────┐
│                    TIER 3 — GameFeature Plugins                 │
│   (Content-specific logic, can depend on all tiers)             │
│                                                                 │
│   Game modes, level-specific encounters, quest logic            │
└──────────────────────────────┬──────────────────────────────────┘
                               │ depends on
┌──────────────────────────────▼──────────────────────────────────┐
│                    TIER 2 — MainGame Module                     │
│   (Core gameplay: characters, controllers, inventory)           │
│                                                                 │
│   Source/S2/ — Foundation, Character, Combat, AI, Items, UI     │
└──────────────────────────────┬──────────────────────────────────┘
                               │ depends on
┌──────────────────────────────▼──────────────────────────────────┐
│                    TIER 1 — Generic Plugins                     │
│   (Reusable systems, zero game-specific dependencies)           │
│                                                                 │
│   GAS, Hitbox, ComboGraph, AI Framework, Team, Audio, Save      │
└─────────────────────────────────────────────────────────────────┘
```

**Key constraint:** Generic plugins (Tier 1) **cannot** depend on MainGame or GameFeature modules. This forces clean API boundaries and makes plugins portable across projects.

### Plugin Catalog (19+ Custom Plugins)

| Domain | Plugin | Purpose |
|--------|--------|---------|
| **Combat** | SipherComboGraph | Visual node-based combo editor with undo/redo and runtime ability integration |
| **Combat** | SipherHitbox | Animation notify-driven hit detection with predicted traces for low-FPS robustness |
| **Combat** | SipherAttributes | GAS attribute set foundation (7 specialized sets) |
| **AI** | SipherAIScalableFramework | Hybrid State Tree + BT framework with coordinator system |
| **AI** | SipherAIBPTools | Blueprint authoring tools for AI designers |
| **Audio** | SipherAudio | Runtime audio framework with editor test harness |
| **Narrative** | SipherSubtitle | Customizable subtitle rendering system |
| **Cinematic** | SipherCutsceneCore / Manager / Tools | Three-module cinematic pipeline |
| **Persistence** | SipherSaveLoadManager | Save/load with checkpoint integration |
| **Gameplay** | SipherTimeDilationManager | Frame-accurate time manipulation for slow-mo and hit stops |
| **Team** | SipherTeam | Faction affiliation and relationship queries |
| **Framework** | SipherCore | Shared types, utilities, and base classes |
| **Framework** | SipherInteractionObjectFramework | Smart Object-based interaction system |
| **Framework** | SipherFABRIK | Full-body IK solution |
| **Framework** | SipherInputReplay | Input recording and deterministic playback |
| **Framework** | SipherMontageStandards | Animation montage naming and section conventions |
| **Tools** | SipherEnemyTools | Content validation for enemy assets |

---

## Combat Systems

The combat pipeline is the project's centerpiece — a deeply integrated stack of GAS, hitbox detection, combo graphs, and a universal damage pipeline that delivers frame-precise, direction-aware melee combat.

### Gameplay Ability System (GAS) Integration

We extend Unreal's GAS with a custom **Ability System Component** that supports runtime data passing through an **Ability Data Queue** pattern. This allows abilities to receive context-specific parameters without subclassing per-variant:

```cpp
// Runtime data passed alongside ability activation
struct FSipherAbilitySpecQueueItem
{
    FGameplayAbilitySpecHandle SpecHandle;

    // Generic data container — abilities introspect this at activation
    TInstancedStruct<FSipherGenericAbilityData> GenericAbilityData;
};

// Activation with data:
bool USipherAbilitySystemComponent::TryActivateAbilityWithData(
    FGameplayAbilitySpecHandle Handle,
    TInstancedStruct<FSipherGenericAbilityData>&& Data)
{
    AbilityDataQueue.Enqueue({ Handle, MoveTemp(Data) });
    return TryActivateAbility(Handle);
}
```

**Why this matters:** Traditional GAS requires creating ability subclasses for each parameter variation (e.g., light attack vs. heavy attack vs. aerial attack). The data queue pattern lets a single ability class handle all variants by reading runtime context from the queue during activation — dramatically reducing class proliferation.

#### Attribute Architecture (7 Specialized Sets)

| Attribute Set | Domain | Key Attributes |
|---------------|--------|----------------|
| Offensive | Attack | AttackPower, CriticalChance, CriticalMultiplier, FinisherDamage |
| Defensive | Defense | DefenseRating, DamageNegation, Vulnerability |
| PlayerCombat | Resources | Stamina, FocusPoints, MagicPool |
| ElementalResistance | Elements | Fire, Ice, Thunder, Earth, Poison resistance |
| CharacterMovement | Mobility | MoveSpeed, DodgeDistance, AgilityStat |
| Consumable | Items | Consumable charges and cooldowns |
| Shield | Guard | ShieldHealth, BlockReduction |

### Universal Damage Pipeline

All damage flows through a **7-stage execution pipeline** — modular passes that can be independently modified, debugged, and extended:

```
  Attacker activates ability
         │
         ▼
  ┌─────────────────────┐
  │ 1. SourceOutputDamage│  Attacker's base damage + crit calculation
  └──────────┬──────────┘
             ▼
  ┌─────────────────────┐
  │ 2. TargetDefense    │  Defender's armor negation + vulnerability
  └──────────┬──────────┘
             ▼
  ┌─────────────────────┐
  │ 3. Immunity         │  Resistance and full immunity checks
  └──────────┬──────────┘
             ▼
  ┌─────────────────────┐
  │ 4. Elemental        │  Elemental damage type processing
  └──────────┬──────────┘
             ▼
  ┌─────────────────────┐
  │ 5. ShieldConsumption│  Shield break mechanics and overflow
  └──────────┬──────────┘
             ▼
  ┌─────────────────────┐
  │ 6. SetAbsoluteDamage│  Override hooks for special scenarios
  └──────────┬──────────┘
             ▼
  ┌─────────────────────┐
  │ 7. FinalApplication │  Apply to Health attribute + broadcast
  └─────────────────────┘
```

Each stage is a separate **Gameplay Effect Execution Calculation** — a design that makes it trivial to add new damage modifiers (e.g., "elemental weakness bonus") without touching existing pipeline stages.

### Direction-Aware Parry System

The parry system uses a **state machine** with directional attack classification — incoming attacks are analyzed by vector math to determine their offensive direction, enabling direction-specific block and parry animations:

```cpp
// Parry state machine
enum class EParryState : uint8
{
    None,           // No parry active
    Anticipation,   // Wind-up frames (can cancel)
    Parrying,       // Active parry window (perfect timing)
    Blocking,       // Extended block window (reduced damage)
    Recovery,       // End-lag (vulnerable)
    Success         // Parry landed → counter-attack window
};

// Attack direction classification for parry response
enum class EDamageOffensiveDirection : uint8
{
    Vertical,       // Overhead strikes
    Horizontal,     // Sweeping attacks
    DiagonalLeft,   // Upper-left to lower-right
    DiagonalRight,  // Upper-right to lower-left
    Center          // Stab / thrust
};
```

The parry system feeds directly into the **riposte chain** — a successful parry opens a window for a direction-matched counter-attack sequence, creating risk/reward depth comparable to Sekiro-style deflection.

### Visual Combo Graph Editor

Combat designers author attack chains in a **node-based visual editor** with full undo/redo support. The graph compiles to runtime state machines that integrate with GAS:

**Node Types:**
- **Input Nodes** — Listen for player input during combo windows
- **Condition Nodes** — Gate transitions on stamina, cooldowns, or tags
- **Execution Nodes** — Trigger montages and gameplay effects
- **Ability Nodes** — Activate GAS abilities via the data queue pattern

**Action Pass Types:**
- `ActivateAbility` — GAS ability activation with runtime data
- `PlayMontage` — Animation playback with section targeting
- `PhysicalAttack` / `SpellAttack` — Melee or ranged damage dispatch
- `CostStat` — Stamina/resource deduction

### Hitbox System

Hitboxes are driven entirely by **Animation Notify States** — animators place notify windows on montages, and the runtime traces weapon socket positions between frames:

**Key features:**
- **Predicted traces** for 25-40 FPS robustness (interpolates missed positions)
- **Per-hit deduplication** via target cache to prevent double-damage
- **Hit stop** with configurable stacking (multiple hits don't compound pause duration beyond a cap)
- **Debug visualization** via console variables for rapid iteration

```cpp
// Hit stop configuration — shipped values after extensive playtesting
struct FHitStopConfig
{
    float Duration = 0.1f;          // Base pause duration
    float MinPlayRate = 0.03f;      // Near-zero but not frozen
    bool  bCosmetic = true;         // Affects animation only, not gameplay
    float StackDecay = 0.5f;        // Each stacked hit adds 50% less
};
```

---

## AI Framework

The AI system is a **hybrid architecture** combining Unreal's State Trees for high-level decision-making with Behavior Trees for tactical execution, coordinated through a centralized **Coordinator** that manages group behavior, formations, and resource budgeting.

### Architecture

```
┌─────────────────────────────────────────────┐
│         AI Coordinator (Global)              │
│  Budget management, threat prioritization    │
│  Formation assignment, group commands        │
└──────────┬──────────────┬───────────────────┘
           │              │
    ┌──────▼──────┐ ┌────▼────────────┐
    │ State Tree  │ │  State Tree     │
    │ (Macro AI)  │ │  (Macro AI)     │   ... per AI entity
    │ Patrol →    │ │  Guard →        │
    │ Alert →     │ │  Investigate →  │
    │ Combat      │ │  Combat         │
    └──────┬──────┘ └────┬────────────┘
           │              │
    ┌──────▼──────┐ ┌────▼────────────┐
    │ Behavior    │ │  Behavior       │
    │ Tree        │ │  Tree           │   ... tactical execution
    │ (Tactics)   │ │  (Tactics)      │
    └─────────────┘ └─────────────────┘
```

### Coordinator System

The Coordinator prevents the classic "one-at-a-time" problem in action games where enemies politely wait their turn. Instead:

- **Attack budgets** limit simultaneous attackers (e.g., max 3 of 8 enemies can swing at once)
- **Formation slots** position enemies in rings/arcs with priority-based assignment
- **Group commands** synchronize behavior (coordinated retreats, flanking maneuvers, staggered attacks)
- **Threat alerting** propagates player detection across nearby groups

### Scalable Difficulty Parameters

Each AI entity has a `SipherAIScalableParametersComponent` that multiplies core attributes:

| Parameter | Effect | Range |
|-----------|--------|-------|
| DamageMultiplier | Outgoing damage scaling | 0.5x – 2.0x |
| HealthMultiplier | Health pool scaling | 0.5x – 3.0x |
| ReactionTimeMultiplier | Decision delay | 0.5x – 2.0x |
| AggressionLevel | Attack frequency | Low / Medium / High |

These are tuned per-difficulty and per-encounter, allowing designers to create dynamic difficulty curves without touching behavior logic.

### Performance: 50+ AI at 60 FPS

Achieving 50+ concurrent AI entities at locked 60 FPS required three key optimizations:

1. **AI LOD System** — Entities beyond camera range or at distance run simplified behavior (fewer perception queries, reduced decision frequency)
2. **Time Slicing** — Group coordination decisions are batched across frames rather than evaluated every tick
3. **Smart Object Pooling** — Interaction points are pre-allocated and recycled instead of spawned dynamically

---

## Character System

### Hierarchy

```
ASipherBasicCharacter
├── Implements 9 interfaces:
│   ├── IAbilitySystemInterface
│   ├── IGameplayTagAssetInterface
│   ├── ILifeStateInterface
│   ├── ICharacterCombatInterface
│   ├── ISipherDomainSystemInterface
│   ├── ICompanionControlInterface
│   ├── ISipherSaveableInterface
│   ├── ISipherCutsceneActorInterface
│   └── IComboCharacterInterface
│
├── ASipherPlayerCharacter
│   └── 60+ gameplay features (movement, combat, abilities, UI)
│
└── ASipherAICharacter
    ├── ASipherAINonPlayerCharacter (friendly NPCs)
    └── ASipherMobCharacterBase (enemies)
```

### Component Architecture

Characters are composed of specialized components rather than monolithic classes:

| Component | Responsibility |
|-----------|---------------|
| `SipherCharacterMovementComponent` | Enhanced movement with animation-aware turning |
| `SipherCharacterLifeStateComponent` | Death handling, respawn triggers, invincibility frames |
| `SipherCharacterStatComponent` | Runtime attribute tracking and UI binding |
| `SipherHitReaction` | Damage impact reactions (light/heavy/knockdown/stagger) |
| `SipherComboManagerComponent` | Combo graph execution and state tracking |
| `SipherCombatExecutionComponent` | Attack mechanics and damage dispatch |
| `SipherDismembermentComponent` | Gore/dismemberment on killing blows |
| `SipherShieldComponentBase` | Guard meter and block reduction |
| `SipherDamageFeedbackComponent` | VFX/SFX resolution for hit effects |

**Design rationale:** This composition-over-inheritance approach means each system can be developed, tested, and iterated independently. Adding dismemberment to a new enemy type is as simple as attaching the component — no subclassing required.

---

## Animation Integration

Combat feel is driven by **100+ Animation Notify States** that synchronize gameplay mechanics to exact animation frames:

### Notify Categories

| Category | Examples | Purpose |
|----------|----------|---------|
| **Hitbox** | `ANS_SocketTracker` | Record weapon socket positions for trace-based hit detection |
| **Parry** | `ANS_ParryWarp`, `ANS_ParryEnduranceWarp` | Root motion warping during parry animations |
| **Combo** | `ANS_PerfectComboWindow`, `ANS_CounterWindow` | Frame-precise input windows for combo transitions |
| **Riposte** | `ANS_RiposteChain` | Counter-attack warp after successful parry |
| **Cinematic** | `AN_StartCinematicQTE` | QTE trigger points during finisher sequences |
| **Stance** | `ANS_StanceWarp` | Smooth stance transitions with motion warping |

This animation-centric approach means **combat designers control timing**, not programmers. A parry window's duration is set by the length of the notify state on the montage — designers adjust feel in the animation editor, not in code.

---

## Performance Engineering

### Async Asset Loading

All soft object references (montages, textures, VFX) are loaded asynchronously to prevent game-thread hitches:

```cpp
// BeginPlay — start async load
void UMyComponent::BeginPlay()
{
    Super::BeginPlay();

    FStreamableManager& Mgr = UAssetManager::Get().GetStreamableManager();
    StreamHandle = Mgr.RequestAsyncLoad(
        MontageRef.ToSoftObjectPath(),
        FStreamableDelegate::CreateUObject(this, &ThisClass::OnMontageLoaded)
    );
}

// EndPlay — release handle to prevent leaks
void UMyComponent::EndPlay(const EEndPlayReason::Type Reason)
{
    if (StreamHandle.IsValid())
    {
        StreamHandle->ReleaseHandle();
    }
    Super::EndPlay(Reason);
}

// Usage — safe access (nullptr if not yet loaded)
UAnimMontage* Montage = MontageRef.Get();
```

**Rule enforced project-wide:** `LoadSynchronous()` is banned. Every asset load goes through `RequestAsyncLoad()` with proper handle cleanup.

### Delegate Pattern

Components expose events through a **private delegate + public getter** pattern to prevent accidental reassignment:

```cpp
// Private delegate — cannot be directly assigned from outside
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnDamageReceived, float, Amount);

UCLASS()
class USipherHealthComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    // Public getter returns reference — callers can bind, but not replace
    FOnDamageReceived& GetOnDamageReceived() { return OnDamageReceived; }

private:
    FOnDamageReceived OnDamageReceived;
};
```

### Gameplay Tags — Compile-Time Safety

All gameplay tags are declared natively for compile-time validation. `RequestGameplayTag()` is banned project-wide:

```cpp
// Header — compile-time tag declaration
UE_DECLARE_GAMEPLAY_TAG_EXTERN(TAG_Combat_State_Parrying);
UE_DECLARE_GAMEPLAY_TAG_EXTERN(TAG_Combat_Damage_Physical);
UE_DECLARE_GAMEPLAY_TAG_EXTERN(TAG_Combat_Immunity_Stagger);

// Source — tag definition
UE_DEFINE_GAMEPLAY_TAG(TAG_Combat_State_Parrying,   "Combat.State.Parrying");
UE_DEFINE_GAMEPLAY_TAG(TAG_Combat_Damage_Physical,  "Combat.Damage.Physical");
UE_DEFINE_GAMEPLAY_TAG(TAG_Combat_Immunity_Stagger, "Combat.Immunity.Stagger");
```

Over **100 native tags** organized by domain — combat, damage types, elements, force effects, AI states, and ability lifecycle.

---

## Key Technical Achievements

<div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1em; margin: 1.5em 0;">

<div style="background:#0d1117; padding:1em 1.5em; border-radius:6px; border-left:4px solid #58a6ff;">

**19+ Custom Plugins**
Modular architecture with enforced three-tier dependency boundaries. Each plugin is independently buildable and testable.

</div>

<div style="background:#0d1117; padding:1em 1.5em; border-radius:6px; border-left:4px solid #f78166;">

**7-Stage Damage Pipeline**
Execution-based damage processing with injectable stages for immunity, elemental, shield, and custom passes.

</div>

<div style="background:#0d1117; padding:1em 1.5em; border-radius:6px; border-left:4px solid #3fb950;">

**50+ AI at 60 FPS**
Hybrid State Tree + BT with coordinator-managed formations, attack budgets, and LOD-based complexity scaling.

</div>

<div style="background:#0d1117; padding:1em 1.5em; border-radius:6px; border-left:4px solid #d2a8ff;">

**100+ Animation Notifies**
Frame-precise combat mechanics authored by designers in the animation editor, not in code.

</div>

</div>

---

## Technologies & Tools

| Category | Technologies |
|----------|-------------|
| **Engine** | Unreal Engine 5.7 (custom modifications) |
| **Languages** | C++ (primary), Blueprints (designer-facing systems) |
| **Core Systems** | Gameplay Ability System, State Trees, Behavior Trees, Smart Objects |
| **Rendering** | DLSS, Streamline, NIS (NVIDIA integrations) |
| **Animation** | Motion Warping, FABRIK IK, Kawaii Physics |
| **Version Control** | Perforce |
| **Platforms** | PC (Win64), PlayStation 5, Xbox Series X |

---

<div style="text-align:center; padding:2em 0; color:#888; font-size:0.9em;">

*This showcase covers architectural decisions and system design patterns. Specific implementation details are under NDA.*

*Built with Unreal Engine 5.7 — C++ throughout.*

</div>
