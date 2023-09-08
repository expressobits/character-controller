using System;
using Godot;

// Ability that adds extra speed when activated

public partial class SprintAbility3D : MovementAbility3D
{
    // Speed to be multiplied when activating the ability
    [Export] public float SpeedMultiplier = 1.6f;

    // Returns a speed modifier, 
    // useful for abilities that when active can change the overall speed of the CharacterController3D, for example the SprintAbility3D.
    public override float GetSpeedModifier()
    {
        if (IsActived())
        {
            return SpeedMultiplier;
        }
        else
        {
            return base.GetSpeedModifier();
        }
    }
}
