using System;
using Godot;

// Character Controller 3D specialized in FPS.
//
// Contains camera information:[br]
// - FOV[br]
// - HeadBob[br]
// - Rotation limits[br]
// - Inputs for camera rotation[br]

public partial class FPSController3D : CharacterController3D
{
    [ExportGroup("FOV")]
    // Speed at which the FOV changes
    [Export] public float FovChangeSpeed = 4f;
    // FOV to be multiplied when active the sprint
    [Export] public float SprintFovMultiplier = 1.1f;
    // FOV to be multiplied when active the crouch
    [Export] public float CrouchFovMultiplier = 0.95f;
    // FOV to be multiplied when active the swim
    [Export] public float SwimFovMultiplier = 1.0f;

    [ExportGroup("Mouse")]
    // Mouse Sensitivity
    [Export] public float MouseSensitivity = 2.0f;
    // Maximum vertical angle the head can aim
    [Export] public float VerticalAngleLimit = 90.0f;

    [ExportGroup("Head Bob - Steps")]
    // Enables bob for made steps
    [Export] public bool StepBobEnabled = true;
    // Difference of step bob movement between vertical and horizontal angle
    [Export] public float VerticalHorizontalRatio = 2;

    [ExportGroup("Head Bob - Jump")]
    // Enables bob for made jumps
    [Export] public bool JumpBobEnabled = true;

    [ExportGroup("Head Bob - Rotation When Move (Quake Like)")]
    // Enables camera angle for the direction the character controller moves
    [Export] public bool RotationToMove = true;
    // Speed at which the camera angle moves
    [Export] public float SpeedRotation = 4.0f;
    // Rotation angle limit per move
    [Export] public float AngleLimitForRotation = 0.1f;

    // [HeadMovement3D] reference, where the rotation of the camera sight is calculated
    private HeadMovement3D head;
    // Camera3D reference
    public Camera3D camera;
    // HeadBob reference
    private HeadBob headBob;
    // Stores normal fov from camera fov
    private float _normalFov;

    public override void _Ready()
    {
        base._Ready();
    }

    // Configure mouse sensitivity, rotation limit angle and head bob
    // After call the base class setup [CharacterController3D].
    public override void Setup()
    {
        base.Setup();
        head = GetNode<HeadMovement3D>("Head");
        camera = GetNode<Camera3D>("Head/Camera");
        headBob = GetNode<HeadBob>("Head/Head Bob");
        _normalFov = camera.Fov;
        head.SetMouseSensitivity(MouseSensitivity);
        head.SetVerticalAngleLimit(VerticalAngleLimit);
        headBob.StepBobEnabled = StepBobEnabled;
        headBob.JumpBobEnabled = JumpBobEnabled;
        headBob.RotationToMove = RotationToMove;
        headBob.SpeedRotation = SpeedRotation;
        headBob.AngleLimitForRotation = AngleLimitForRotation;
        headBob.VerticalHorizontalRatio = VerticalHorizontalRatio;
        headBob.SetupStepBob(StepInterval * 2);
    }

    // Rotate head based on mouse axis parameter.
    // This function call [b]head.rotate_camera()[/b].
    public void RotateHead(Vector2 mouseAxis)
    {
        head.RotateCamera(mouseAxis);
    }

    // Call to move the character.
    // First it is defined what the direction of movement will be, whether it is vertically or not 
    // based on whether swim or fly mode is active.
    // Afterwards, the [b]move()[/b] of the base class [CharacterMovement3D] is called
    // It is then called functions responsible for head bob if necessary.
    public override void Move(float _delta, Vector2 inputAxis = default(Vector2), bool inputJump = false, bool inputCrouch = false, bool inputSprint = false, bool inputSwimDown = false, bool inputSwimUp = false)
    {
        if (IsFlyMode() || IsFloating())
            _directionBaseNode = head;
        else
            _directionBaseNode = this;

        base.Move(_delta, inputAxis, inputJump, inputCrouch, inputSprint, inputSwimDown, inputSwimUp);

        if (!IsFlyMode() && !SwimAbility.IsFloating() && !SwimAbility.IsSubmerged())
        {
            camera.Fov = Mathf.Lerp(camera.Fov, _normalFov, _delta * FovChangeSpeed);
        }

        CheckHeadBob(_delta, inputAxis);
    }

    private void CheckHeadBob(float _delta, Vector2 inputAxis)
    {
        headBob.HeadBobProcess(_horizontalVelocity, inputAxis, IsSprinting(), IsOnFloor(), _delta);
    }

    public override void OnJumped()
    {
        base.OnJumped();
        headBob.DoBobJump();
        headBob.ResetCycles();
    }
}
