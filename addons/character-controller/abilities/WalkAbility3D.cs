using System;
using Godot;

// Basic movement ability

public partial class WalkAbility3D : MovementAbility3D
{
    // Time for the character to reach full speed
    [Export] public float Acceleration = 8f;

    // Time for the character to stop walking
    [Export] public float Deceleration = 10f;

    // Sets control in the air
    [Export(PropertyHint.Range, "0.0, 1.0, 0.05")] public float AirControl = 0.3f;

    // Takes direction of movement from input and turns it into horizontal velocity.
    public override Vector3 Apply(Vector3 velocity, float speed, bool isOnFloor, Vector3 direction, float delta)
    {
        if (!IsActived())
            return velocity;

        // Using only the horizontal velocity, interpolate towards the input.
        Vector3 tempVel = velocity;
        tempVel.Y = 0f;

        float tempAccel;
        Vector3 target = direction * speed;

        if (direction.Dot(tempVel) > 0f)
            tempAccel = Acceleration;
        else
            tempAccel = Deceleration;

        if (!isOnFloor)
            tempAccel *= AirControl;

        tempVel = tempVel.Lerp(target, tempAccel * delta);

        return new Vector3(tempVel.X, velocity.Y, tempVel.Z);
    }
}
