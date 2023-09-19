using System;
using Godot;


// Ability that gives free movement to CharacterController 3D completely ignoring gravity.

public partial class FlyAbility3D : MovementAbility3D
{
    // Speed modifier while this ability is active
    [Export] public float SpeedModifier = 2.0f;

    // Get actual speed modifier
    public override float GetSpeedModifier()
    {
        if (IsActived())
        {
            return SpeedModifier;
        }
        else
        {
            return base.GetSpeedModifier();
        }
    }

    // Apply velocity to CharacterController3D
    public override Vector3 Apply(Vector3 velocity, float speed, bool isOnFloor, Vector3 direction, float delta)
    {
        if (!IsActived())
            return velocity;

        // Using only the horizontal velocity, interpolate towards the input.
        Vector3 tempVel = velocity;
        tempVel = direction * speed;
        return new Vector3(tempVel.X, tempVel.Y, tempVel.Z);
    }
}