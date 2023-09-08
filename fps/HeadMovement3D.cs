using System;
using Godot;

// Node that moves the character's head
// To move just call the function [b]rotate_camera[/b]

public partial class HeadMovement3D : Marker3D
{
    // Mouse sensitivity of rotation move
    [Export] public float MouseSensitivity = 2.0f;

    // Vertical angle limit of rotation move
    [Export] public float VerticalAngleLimit = 90.0f;

    // Actual rotation of movement
    private Vector3 _actualRotation = new Vector3(0, 0, 0);

    public override void _Ready()
    {
        _actualRotation.Y = GetOwner<Node3D>().Rotation.Y;
    }

    // Define mouse sensitivity
    public void SetMouseSensitivity(float sensitivity)
    {
        MouseSensitivity = sensitivity;
    }

    // Define vertical angle limit for rotation movement of head
    public void SetVerticalAngleLimit(float limit)
    {
        VerticalAngleLimit = Mathf.DegToRad(limit);
    }

    // Rotates the head of the character that contains the camera used by
    // [FPSController3D].
    // Vector2 is sent with reference to the input of a mouse as an example
    public void RotateCamera(Vector2 mouseAxis)
    {
        // Horizontal mouse look.
        _actualRotation.Y -= mouseAxis.X * (MouseSensitivity / 1000);
        // Vertical mouse look.
        _actualRotation.X = Mathf.Clamp(_actualRotation.X - mouseAxis.Y * (MouseSensitivity / 1000), -VerticalAngleLimit, VerticalAngleLimit);

        GetOwner<Node3D>().Rotation = new Vector3(GetOwner<Node3D>().Rotation.X, _actualRotation.Y, GetOwner<Node3D>().Rotation.Z);
        Rotation = new Vector3(_actualRotation.X, Rotation.Y, Rotation.Z);
    }
}
