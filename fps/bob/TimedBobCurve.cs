using System;
using Godot;

// Timed Bob Curve.
// Used by [HeadMovement] for a jump bob.
[GlobalClass]
public partial class TimedBobCurve : Resource
{
    // Duration of the entire bob process
    [Export] public float Duration { get; set; } = 0.2f;
    // Max amount in bob offset
    [Export] public float Amount { get; set; } = 0.1f;

    // Actual offset of bob
    private float _offset = 0.0f;
    // Actual direction flag of bob
    // true if initial state
    // false for final state
    private bool _direction = true;
    // Current time for current direction flag
    private float _time;

    public TimedBobCurve()
    {
        _time = Duration;
    }

    // Return actual offset of bob
    public float GetOffset()
    {
        return _offset;
    }

    // Init bob timer
    public void DoBobCycle()
    {
        _time = Duration;
        _direction = false;
    }

    // Tick process of bob timer
    public void BobProcess(float delta)
    {
        if (_time > 0)
        {
            _time -= delta;

            if (_direction)
            {
                _offset = Mathf.Lerp(0f, Amount, _time / Duration);
            }
            else
            {
                _offset = Mathf.Lerp(Amount, 0f, _time / Duration);
            }

            if (_time < 0 && !_direction)
            {
                BackDoBobCycle();
            }
        }
    }

    private void BackDoBobCycle()
    {
        _time = Duration;
        _direction = true;
    }
}
