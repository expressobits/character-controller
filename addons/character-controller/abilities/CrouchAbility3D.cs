using System;
using Godot;

// Crouch Ability, change size collider and velocity of CharacterController3D.

public partial class CrouchAbility3D : MovementAbility3D
{
    // Speed multiplier when crouch is actived
    [Export] public float SpeedMultiplier = 0.7f;

    // Collider that changes size when in crouch state
    [Export] public CollisionShape3D Collision;

    // Raycast that checks if it is possible to exit the crouch state
    [Export] public RayCast3D HeadCheck;

    // Collider height when crouch actived
    [Export] public float HeightInCrouch = 1.0f;

    // Collider height when crouch deactived
    [Export] public float DefaultHeight = 2.0f;

    // Applies slow if crouch is enabled
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

    // Set collision height
    public override Vector3 Apply(Vector3 velocity, float speed, bool isOnFloor, Vector3 direction, float delta)
    {
        if (IsActived())
        {
            Collision.Shape.Set("height", Collision.Shape.Get("height").AsSingle() - (delta * 8));
        }
        else if (!HeadCheck.IsColliding())
        {
            Collision.Shape.Set("height", Collision.Shape.Get("height").AsSingle() + (delta * 8));
        }

        Collision.Shape.Set("height", Mathf.Clamp(Collision.Shape.Get("height").AsSingle(), HeightInCrouch, DefaultHeight));

        return velocity;
    }
}