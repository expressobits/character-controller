using System;
using System.Linq;
using Godot;
using Godot.Collections;

// Main class of the addon, contains abilities array for character movements.

public partial class CharacterController3D : CharacterBody3D
{
    // Emitted when the character controller performs a step, called at the end of 
    // the [b]move()[/b] 
    // function when a move accumulator for a step has ended.
    [Signal] public delegate void SteppedEventHandler();
    // Emitted when touching the ground after being airborne, called in the 
    // [b]move()[/b] function.
    [Signal] public delegate void LandedEventHandler();
    // Emitted when a jump is processed, is called when [JumpAbility3D] is active.
    [Signal] public delegate void JumpedEventHandler();
    // Emitted when a crouch is started, is called when [CrouchAbility3D] is active.
    [Signal] public delegate void CrouchedEventHandler();
    // Emitted when a crouch is finished, is called when [CrouchAbility3D] is 
    // deactive.
    [Signal] public delegate void UncrouchedEventHandler();
    // Emitted when a sprint started, is called when [SprintAbility3D] is active.
    [Signal] public delegate void SprintedEventHandler();
    // Emitted when a fly mode is started, called when [FlyModeAbility3D] is active.
    [Signal] public delegate void FlyModeActivedEventHandler();
    // Emitted when a fly mode is finished, called when [FlyModeAbility3D] is 
    // deactive.
    [Signal] public delegate void FlyModeDeactivedEventHandler();
    // Emitted when emerged in water.
    // Called when the height of the water depth returned from the 
    // [b]get_depth_on_water()[/b] function of [SwimAbility3D] is greater than the 
    // minimum height defined in [b]submerged_height[/b].
    [Signal] public delegate void EmergedEventHandler();
    // Emitted when submerged in water.
    // Called when the water depth height returned from the 
    // [b]get_depth_on_water()[/b] function of [SwimAbility3D] is less than the 
    // minimum height defined in [b]submerged_height[/b].
    [Signal] public delegate void SubmergedEventHandler();
    // Emitted when it starts to touch the water.
    [Signal] public delegate void EnteredTheWaterEventHandler();
    // Emitted when it stops touching the water.
    [Signal] public delegate void ExitTheWaterEventHandler();
    // Emitted when water starts to float.
    // Called when the height of the water depth returned from the 
    // [b]get_depth_on_water()[/b] function of [SwimAbility3D] is greater than the 
    // minimum height defined in [b]floating_height[/b].
    [Signal] public delegate void StartedFloatingEventHandler();
    // Emitted when water stops floating.
    // Called when the water depth height returned from the 
    // [b]get_depth_on_water()[/b] function of [SwimAbility3D] is less than the 
    // minimum height defined in [b]floating_height[/b].
    [Signal] public delegate void StoppedFloatingEventHandler();

    [ExportGroup("Movement")]
    // Controller Gravity Multiplier
    // The higher the number, the faster the controller will fall to the ground and 
    // your jump will be shorter.
    [Export] public float GravityMultiplier = 3f;
    // Controller base speed
    // Note: this speed is used as a basis for abilities to multiply their 
    // respective values, changing it will have consequences on [b]all abilities[/b]
    // that use velocity.
    [Export] public int Speed = 10;
    // Time for the character to reach full speed
    [Export] public int Acceleration = 8;
    // Time for the character to stop walking
    [Export] public int Deceleration = 10;
    // Sets control in the air
    [Export] public float AirControl = 0.3f;
    [ExportGroup("Sprint")]
    // Speed to be multiplied when active the ability
    [Export] public float SprintSpeedMultiplier = 1.6f;
    [ExportGroup("Footsteps")]
    // Maximum counter value to be computed one step
    [Export] public float StepLengthen = 0.7f;
    // Value to be added to compute a step, each frame that the character is walking this value 
    // is added to a counter
    [Export] public float StepInterval = 6f;
    [ExportGroup("Crouch")]
    // Collider height when crouch actived
    [Export] public float HeightInCrouch = 1f;
    // Speed multiplier when crouch is actived
    [Export] public float CrouchSpeedMultiplier = 0.7f;
    [ExportGroup("Jump")]
    // Jump/Impulse height
    [Export] public int JumpHeight = 10;
    [ExportGroup("Fly")]
    // Speed multiplier when fly mode is actived
    [Export] public int FlyModeSpeedModifier = 2;
    [ExportGroup("Swim")]
    // Minimum height for [CharacterController3D] to be completely submerged in water.
    [Export] public float SubmergedHeight = 0.36f;
    // Minimum height for [CharacterController3D] to be float in water.
    [Export] public float FloatingHeight = 0.75f;
    // Speed multiplier when floating water
    [Export] public float OnWaterSpeedMultiplier = 0.75f;
    // Speed multiplier when submerged water
    [Export] public float SubmergedSpeedMultiplier = 0.5f;
    [ExportGroup("Abilities")]
    // List of movement skills to be used in processing this class.
    [Export] public Array<NodePath> AbilitiesPath = new Array<NodePath>();

    // List of movement skills to be used in processing this class.
    private Array<MovementAbility3D> _abilities = new Array<MovementAbility3D>();
    // Result direction of inputs sent to [b]move()[/b].
    private Vector3 _direction = new Vector3();
    // Current counter used to calculate next step.
    private float _stepCycle = 0;
    // Maximum value for _step_cycle to compute a step.
    private float _nextStep = 0;
    // Character controller horizontal speed. !!!!!!!!!
    public Vector3 _horizontalVelocity = new Vector3();
    // Base transform node to direct player movement
    // Used to differentiate fly mode/swim moves from regular character movement.
    public Node3D _directionBaseNode;  // !!!!!!!!!

    // Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
    private float Gravity;
    // Collision of character controller.
    private CollisionShape3D Collision;
    // Above head collision checker, used for crouching and jumping.
    private RayCast3D HeadCheck;
    // Basic movement ability.
    public WalkAbility3D WalkAbility;
    // Crouch Ability, change size collider and velocity.
    public CrouchAbility3D CrouchAbility;
    // Ability that adds extra speed when actived.
    public SprintAbility3D SprintAbility;
    // Simple ability that adds a vertical impulse when actived (Jump).
    public JumpAbility3D JumpAbility;
    // Ability that gives free movement completely ignoring gravity.
    public FlyAbility3D FlyAbility;
    // Swimming ability.
    public SwimAbility3D SwimAbility;
    // Stores normal speed
    private int _normalSpeed;
    // True if in the last frame it was on the ground
    private bool _lastIsOnFloor = false;
    // Default controller height, affects collider
    private float _defaultHeight;

    public override void _Ready()
    {
        Setup();

    }

    // Loads all character controller skills and sets necessary variables
    public virtual void Setup()
    {
        _directionBaseNode = this;
        _abilities = LoadNodes(AbilitiesPath);
        Gravity = (float)ProjectSettings.GetSetting("physics/3d/default_gravity").AsDouble() * GravityMultiplier;
        Collision = GetNode<CollisionShape3D>("Collision");
        HeadCheck = GetNode<RayCast3D>("Head Check");
        WalkAbility = GetNode<WalkAbility3D>("Walk Ability 3D");
        CrouchAbility = GetNode<CrouchAbility3D>("Crouch Ability 3D");
        SprintAbility = GetNode<SprintAbility3D>("Sprint Ability 3D");
        JumpAbility = GetNode<JumpAbility3D>("Jump Ability 3D");
        FlyAbility = GetNode<FlyAbility3D>("Fly Ability 3D");
        SwimAbility = GetNode<SwimAbility3D>("Swim Ability 3D");
        _defaultHeight = (float)Collision.Shape.Get("height");
        _normalSpeed = Speed;
        ConnectSignals();
        StartVariables();
    }

    // Moves the character controller.
    // parameters are inputs that are sent to be handled by all abilities.
    public virtual void Move(float delta, Vector2 inputAxis = new Vector2(), bool inputJump = false, bool inputCrouch = false, bool inputSprint = false, bool inputSwimDown = false, bool inputSwimUp = false)
    {
        Vector3 direction = DirectionInput(inputAxis, inputSwimDown, inputSwimUp, _directionBaseNode);
        Vector3 velocity = Velocity;

        if (!SwimAbility.IsFloating())
        {
            CheckLanded();
        }

        if (!JumpAbility.IsActived() && !IsFlyMode() && !IsSubmerged() && !IsFloating())
        {
            velocity.Y -= Gravity * delta;
        }

        SwimAbility.SetActive(!FlyAbility.IsActived());
        JumpAbility.SetActive(inputJump && IsOnFloor() && !HeadCheck.IsColliding());
        WalkAbility.SetActive(!IsFlyMode() && !SwimAbility.IsFloating());
        CrouchAbility.SetActive(inputCrouch && IsOnFloor() && !IsFloating() && !IsSubmerged() && !IsFlyMode());
        SprintAbility.SetActive(inputSprint && IsOnFloor() && inputAxis.X >= 0.5 && !IsCrouching() && !IsFlyMode() && !SwimAbility.IsFloating() && !SwimAbility.IsSubmerged());

        float multiplier = 1.0f;

        foreach (var ability in _abilities)
        {
            multiplier *= ability.GetSpeedModifier();
        }

        Speed = (int)(_normalSpeed * multiplier);

        foreach (var ability in _abilities)
        {
            velocity = ability.Apply(velocity, Speed, IsOnFloor(), direction, delta);
        }

        _horizontalVelocity = new Vector3(velocity.X, 0.0f, velocity.Z);

        if (!IsFlyMode() && !SwimAbility.IsFloating() && !SwimAbility.IsSubmerged())
        {
            CheckStep(delta);
        }

        Velocity = velocity;
        MoveAndSlide();
    }

    // Returns true if the character controller is crouched
    public bool IsCrouching()
    {
        return CrouchAbility.IsActived();
    }

    // Returns true if the character controller is sprinting
    public bool IsSprinting()
    {
        return SprintAbility.IsActived();
    }

    // Returns true if the character controller is in fly mode active
    public bool IsFlyMode()
    {
        return FlyAbility.IsActived();
    }

    // Returns the speed of character controller
    public float GetSpeed()
    {
        return Speed;
    }

    // Returns true if the character controller is in water
    public bool IsOnWater()
    {
        return SwimAbility.IsOnWater();
    }

    // Returns true if the character controller is floating in water
    public bool IsFloating()
    {
        return SwimAbility.IsFloating();
    }

    // Returns true if the character controller is submerged in water
    public bool IsSubmerged()
    {
        return SwimAbility.IsSubmerged();
    }

    public void ResetStep()
    {
        _nextStep = _stepCycle + StepInterval;
    }

    public Array<MovementAbility3D> LoadNodes(Array<NodePath> nodePaths)
    {
        var nodes = new Array<MovementAbility3D>();

        foreach (var nodePath in nodePaths)
        {
            Node node = GetNode(nodePath);
            if (node != null)
            {
                MovementAbility3D ability = node as MovementAbility3D;
                if (ability != null)
                {
                    nodes.Add(ability);
                }
            }
        }

        return nodes;
    }

    public void ConnectSignals()
    {
        CrouchAbility.Actived += OnCrouched;
        CrouchAbility.Deactived += OnUncrouched;
        SprintAbility.Actived += OnSprinted;
        JumpAbility.Actived += OnJumped;
        FlyAbility.Actived += OnFlyModeActived;
        FlyAbility.Deactived += OnFlyModeDeactived;
        SwimAbility.Actived += OnSwimAbilitySubmerged;
        SwimAbility.Deactived += OnSwimAbilityEmerged;
        SwimAbility.StartedFloating += OnSwimAbilityStartedFloating;
        SwimAbility.StoppedFloating += OnSwimAbilityStoppedFloating;
        SwimAbility.EnteredTheWater += OnSwimAbilityEnteredTheWater;
        SwimAbility.ExitTheWater += OnSwimAbilityExitTheWater;
    }

    public void StartVariables()
    {
        WalkAbility.Acceleration = Acceleration;
        WalkAbility.Deceleration = Deceleration;
        WalkAbility.AirControl = AirControl;
        SprintAbility.SpeedMultiplier = SprintSpeedMultiplier;
        CrouchAbility.SpeedMultiplier = CrouchSpeedMultiplier;
        CrouchAbility.DefaultHeight = _defaultHeight;
        CrouchAbility.HeightInCrouch = HeightInCrouch;
        CrouchAbility.Collision = Collision;
        CrouchAbility.HeadCheck = HeadCheck;
        JumpAbility.Height = JumpHeight;
        FlyAbility.SpeedModifier = FlyModeSpeedModifier;
        SwimAbility.SubmergedHeight = SubmergedHeight;
        SwimAbility.FloatingHeight = FloatingHeight;
        SwimAbility.OnWaterSpeedMultiplier = OnWaterSpeedMultiplier;
        SwimAbility.SubmergedSpeedMultiplier = SubmergedSpeedMultiplier;
    }

    public void CheckLanded()
    {
        if (IsOnFloor() && !_lastIsOnFloor)
        {
            EmitSignal(SignalName.Landed);
            ResetStep();
        }
        _lastIsOnFloor = IsOnFloor();
    }

    public void CheckStep(float delta)
    {
        if (IsStep(_horizontalVelocity.Length(), IsOnFloor(), delta))
        {
            Step(IsOnFloor());
        }
    }

    public Vector3 DirectionInput(Vector2 input, bool inputDown, bool inputUp, Node3D aimNode)
    {
        _direction = new Vector3();

        var aim = aimNode.GlobalTransform.Basis;

        if (input.X >= 0.5f)
        {
            _direction -= aim.Z;
        }
        if (input.X <= -0.5f)
        {
            _direction += aim.Z;
        }
        if (input.Y <= -0.5f)
        {
            _direction -= aim.X;
        }
        if (input.Y >= 0.5f)
        {
            _direction += aim.X;
        }
        // NOTE: For free-flying and swimming movements
        if (IsFlyMode() || IsFloating())
        {
            if (inputUp)
            {
                _direction.Y += 1.0f;
            }
            else if (inputDown)
            {
                _direction.Y -= 1.0f;
            }
        }
        else
        {
            _direction.Y = 0;
        }
        return _direction.Normalized();
    }

    public bool Step(bool isOnFloor)
    {
        ResetStep();
        if (isOnFloor)
        {
            EmitSignal(SignalName.Stepped);
            return true;
        }
        return false;
    }

    public bool IsStep(float velocity, bool isOnFloor, float delta)
    {
        if (Mathf.Abs(velocity) < 0.1f)
        {
            return false;
        }
        _stepCycle += ((velocity + StepLengthen) * delta);
        if (_stepCycle <= _nextStep)
        {
            return false;
        }
        return true;
    }

    // Bubbly signals -_-
    public void OnFlyModeActived()
    {
        EmitSignal(SignalName.FlyModeActived);
    }

    public void OnFlyModeDeactived()
    {
        EmitSignal(SignalName.FlyModeDeactived);
    }

    public void OnCrouched()
    {
        EmitSignal(SignalName.Crouched);
    }

    public void OnUncrouched()
    {
        EmitSignal(SignalName.Uncrouched);
    }

    public void OnSprinted()
    {
        EmitSignal(SignalName.Sprinted);
    }

    public virtual void OnJumped()
    {
        EmitSignal(SignalName.Jumped);
    }

    public void OnSwimAbilityEmerged()
    {
        EmitSignal(SignalName.Emerged);
    }

    public void OnSwimAbilitySubmerged()
    {
        EmitSignal(SignalName.Submerged);
    }

    public void OnSwimAbilityEnteredTheWater()
    {
        EmitSignal(SignalName.EnteredTheWater);
    }

    public void OnSwimAbilityExitTheWater()
    {
        EmitSignal(SignalName.ExitTheWater);
    }

    public void OnSwimAbilityStartedFloating()
    {
        EmitSignal(SignalName.StartedFloating);
    }

    public void OnSwimAbilityStoppedFloating()
    {
        EmitSignal(SignalName.StoppedFloating);
    }
}
