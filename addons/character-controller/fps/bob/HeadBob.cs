using System;
using Godot;

// HeadBob Effect for [FPSController3D]

public partial class HeadBob : Node
{
    // Node that will receive the headbob effect
    [Export] public NodePath HeadPath;

    [ExportGroup("Step Bob")]
    // Enables the headbob effect for the steps taken
    [Export] public bool StepBobEnabled = true;
    // Maximum range value of headbob
    [Export] public Vector2 BobRange = new Vector2(0.07f, 0.07f);
    // Curve where bob happens
    [Export] public Curve BobCurve;
    // Curve Multiplier
    [Export] public Vector2 CurveMultiplier = new Vector2(2f, 2f);
    // Difference of step headbob movement between vertical and horizontal angle
    [Export] public float VerticalHorizontalRatio = 2f;

    [ExportGroup("Jump Bob")]
    // Enables bob for made jumps
    [Export] public bool JumpBobEnabled = true;
    // Resource that stores information from bob lerp jump
    [Export] public TimedBobCurve TimedBobCurve;

    [ExportGroup("Rotation To Move (Quake Like)")]
    // Enables camera angle for the direction the character controller moves
    [Export] public bool RotationToMove = true;
    // Speed at which the camera angle moves
    [Export] public float SpeedRotation = 4.0f;
    // Rotation angle limit per move
    [Export] public float AngleLimitForRotation = 0.1f;

    // Node that will receive the headbob effect
    private Node3D _head;
    // Actual speed of headbob
    private float _speed = 0f;
    // Actual speed of headbob
    private Vector3 _originalPosition = new Vector3(0, 0, 0);
    // Store original rotation of head for headbob reference
    private Vector3 _originalRotation = new Vector3(0, 0, 0);

    // Actual cycle x of step headbob
    private float _cyclePositionX = 0f;
    // Actual cycle y of step headbob
    private float _cyclePositionY = 0f;
    // Actual interval of step headbob
    private float _stepInterval = 0f;

    public override void _Ready()
    {
        base._Ready();
        _head = GetNode<Node3D>(HeadPath);
        _originalPosition = _head.Position;
        _originalRotation = _head.Rotation;
    }

    // Setup bob with bob base interval
    public void SetupStepBob(float stepInterval)
    {
        _stepInterval = stepInterval;
    }

    // Applies step headbob and rotation headbob (quake style).
    public void HeadBobProcess(Vector3 horizontalVelocity, Vector2 inputAxis, bool isSprint, bool isOnFloor, float delta)
    {
        if (TimedBobCurve != null)
        {
            TimedBobCurve.BobProcess(delta);
        }

        Vector3 newPosition = _originalPosition;
        Vector3 newRotation = _originalRotation;

        if (StepBobEnabled)
        {
            if (isOnFloor)
            {
                newPosition += DoHeadBob(horizontalVelocity.Length(), delta);
            }
        }

        if (TimedBobCurve != null)
        {
            newPosition.Y -= TimedBobCurve.GetOffset();
        }

        if (isSprint)
        {
            inputAxis *= 2;
        }

        if (RotationToMove)
        {
            newRotation += HeadBobRotation(inputAxis.X, inputAxis.Y, delta);
        }

        _head.Position = newPosition;
        _head.Rotation = newRotation;
    }

    // Apply headbob jump
    public void DoBobJump()
    {
        if (TimedBobCurve != null)
        {
            TimedBobCurve.DoBobCycle();
        }
    }

    // Resets head bob step cycles
    public void ResetCycles()
    {
        _cyclePositionX = 0;
        _cyclePositionY = 0;
    }

    private Vector3 HeadBobRotation(float x, float z, float delta)
    {
        Vector3 targetRotation = new Vector3(x * AngleLimitForRotation, 0f, -z * AngleLimitForRotation);
        return _head.Rotation.Lerp(targetRotation, SpeedRotation * delta); ;
    }

    private Vector3 DoHeadBob(float speed, float delta)
    {
        if (BobCurve == null)
            return new Vector3(0, 0, 0);

        float xPos = BobCurve.Sample(_cyclePositionX) * CurveMultiplier.X * BobRange.X;
        float yPos = BobCurve.Sample(_cyclePositionY) * CurveMultiplier.Y * BobRange.Y;

        float tickSpeed = (speed * delta) / _stepInterval;
        _cyclePositionX += tickSpeed;
        _cyclePositionY += tickSpeed * VerticalHorizontalRatio;

        if (_cyclePositionX > 1)
        {
            _cyclePositionX -= 1;
        }

        if (_cyclePositionY > 1)
        {
            _cyclePositionY -= 1;
        }

        return new Vector3(xPos, yPos, 0);
    }
}
