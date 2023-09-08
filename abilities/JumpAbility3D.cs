using System;
using Godot;

// Simple ability that adds a vertical impulse when activated (Jump)

public partial class JumpAbility3D : MovementAbility3D
{
    // Jump/Impulse height
    [Export] public float Height = 10.0f;

    // Change vertical velocity of CharacterController3D
    public override Vector3 Apply(Vector3 velocity, float speed, bool isOnFloor, Vector3 direction, float delta)
    {
        if (!IsActived())
            return velocity;

        // Using only the horizontal velocity, interpolate towards the input.
        Vector3 tempVel = velocity;
        tempVel.Y = Height;

        return new Vector3(tempVel.X, tempVel.Y, tempVel.Z);
    }
}
