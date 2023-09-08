using System;
using Godot;

// Swim ability of CharacterController3D.
//
// There are three possible states: 
// - Touching water
// - Floating in water
// - Submerged
//
// Note: The actived and deactived signals are emitted when it is
// submerged(active) and surfaced(deactived)

public partial class SwimAbility3D : MovementAbility3D
{
    // Emitted when character controller touched water
    [Signal] public delegate void EnteredTheWaterEventHandler();

    // Emitted when character controller stopped touching water
    [Signal] public delegate void ExitTheWaterEventHandler();

    // Emitted when we start to float in water
    [Signal] public delegate void StartedFloatingEventHandler();

    // Emitted when we stop to float in water
    [Signal] public delegate void StoppedFloatingEventHandler();

    // Minimum height for CharacterController3D to be completely submerged in water
    [Export] public float SubmergedHeight = 0.36f;

    // Minimum height for CharacterController3D to be float in water
    [Export] public float FloatingHeight = 0.55f;

    // Speed multiplier when floating in water
    [Export] public float OnWaterSpeedMultiplier = 0.75f;

    // Speed multiplier when submerged in water
    [Export] public float SubmergedSpeedMultiplier = 0.5f;

    private RayCast3D _raycast;
    private bool _isOnWater;
    private bool _isFloating;
    private bool _wasIsOnWater;
    private bool _wasIsFloating;
    private float _depthOnWater;

    public override void _Ready()
    {
        base._Ready();
        _raycast = GetNode<RayCast3D>("RayCast3D");
        _isOnWater = false;
        _isFloating = false;
        _wasIsOnWater = false;
        _wasIsFloating = false;
        _depthOnWater = 0.0f;
    }

    public override float GetSpeedModifier()
    {
        if (IsActived())
            return SubmergedSpeedMultiplier;
        if (IsFloating())
            return OnWaterSpeedMultiplier;
        return base.GetSpeedModifier();
    }

    public override void SetActive(bool a)
    {
        _isOnWater = _raycast.IsColliding();
        _depthOnWater = _isOnWater ? -_raycast.ToLocal(_raycast.GetCollisionPoint()).Y : 2.1f;

        base.SetActive(_depthOnWater < SubmergedHeight && _isOnWater && a);
        _isFloating = _depthOnWater < FloatingHeight && _isOnWater && a;

        if (IsOnWater() && !_wasIsOnWater)
        {
            EmitSignal(SignalName.EnteredTheWater);
        }

        else if (!IsOnWater() && _wasIsOnWater)
        {
            EmitSignal(SignalName.ExitTheWater);
        }


        if (IsFloating() && !_wasIsFloating)
        {
            EmitSignal(SignalName.StartedFloating);
        }

        else if (!IsFloating() && _wasIsFloating)
        {
            EmitSignal(SignalName.StoppedFloating);
        }

        _wasIsOnWater = _isOnWater;
        _wasIsFloating = _isFloating;
    }

    public override Vector3 Apply(Vector3 velocity, float speed, bool isOnFloor, Vector3 direction, float delta)
    {
        if (!IsFloating())
            return velocity;

        Vector3 tempVel = velocity;

        float depth = FloatingHeight - GetDepthOnWater();
        tempVel = direction * speed;

        if (depth < 0.1f)
        {
            // Prevent free sea movement from exceeding the water surface
            tempVel.Y = Math.Min(velocity.Y, 0);
        }

        return new Vector3(tempVel.X, tempVel.Y, tempVel.Z);
    }

    // Returns true if we are touching the water
    public bool IsOnWater()
    {
        return _isOnWater;
    }

    // Returns true if we are floating in water
    public bool IsFloating()
    {
        return _isFloating;
    }

    // Returns true if we are submerged in water
    public bool IsSubmerged()
    {
        return IsActived();
    }

    // Returns the height of the water in CharacterController3D.
    // 2.1 or more - Above water level
    // 2 - If it's touching our feet
    // 0 - If we just got submerged
    public float GetDepthOnWater()
    {
        return _depthOnWater;
    }
}
