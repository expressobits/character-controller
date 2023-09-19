using System;
using Godot;

// Movement skill abstract class.
// 

public partial class MovementAbility3D : Node3D
{
    // It contains a flag to enable/disable the movement skill, signals emitted when this flag was modified.
    [Export] private bool _active = false;
    private bool _lastActive = false;

    // Emitted when ability has been active, is called when [b]set_active()[/b] is set to true
    [Signal] public delegate void ActivedEventHandler();
    // Emitted when ability has been deactive, is called when [b]set_active()[/b] is set to false
    [Signal] public delegate void DeactivedEventHandler();

    // Returns a speed modifier, 
    // useful for abilities that when active can change the overall speed of the [CharacterController3D], for example the [SprintAbility3D].
    public virtual float GetSpeedModifier()
    {
        return 1.0f;
    }

    // Returns true if ability is active
    public bool IsActived()
    {
        return _active;
    }

    // Defines whether or not to activate the ability
    public virtual void SetActive(bool isActive)
    {
        _lastActive = _active;
        _active = isActive;

        if (_lastActive != _active)
        {
            if (_active)
            {
                EmitSignal(SignalName.Actived);
            }
            else
            {
                EmitSignal(SignalName.Deactived);
            }
        }
    }

    // Change current velocity of [CharacterController3D].
    // In this function abilities can change the way the character controller behaves based on speeds and other parameters received.
    public virtual Vector3 Apply(Vector3 velocity, float speed, bool isOnFloor, Vector3 direction, float delta)
    {
        return velocity;
    }
}
