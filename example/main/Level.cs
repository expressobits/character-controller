using Godot;
using System;
using System.Collections.ObjectModel;

public partial class Level : Node3D
{
    [Export] public bool FastClose { get; set; } = true;

    public override void _Ready()
    {
        if (!OS.IsDebugBuild())
        {
            FastClose = false;
        }

        if (FastClose)
        {
            GD.Print("** Fast Close enabled in the 'Level.cs' script **");
            GD.Print("** 'Esc' to close 'Shift + F1' to release mouse **");
        }

        SetProcessInput(FastClose);
    }

    public override void _Input(InputEvent @event)
    {
        if (@event.IsActionPressed("ui_cancel"))
        {
            GetTree().Quit(); // Quits the game
        }

        if (@event.IsActionPressed("change_mouse_input"))
        {
            switch (Input.MouseMode)
            {
                case Input.MouseModeEnum.Captured:
                    Input.MouseMode = Input.MouseModeEnum.Visible;
                    break;
                case Input.MouseModeEnum.Visible:
                    Input.MouseMode = Input.MouseModeEnum.Captured;
                    break;
            }
        }
    }

    // Capture mouse if clicked on the game, needed for HTML5
    // Called when an InputEvent hasn't been consumed by _input() or any GUI item
    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event is InputEventMouseButton eventMouseButton)
        {
            if (((int)eventMouseButton.ButtonIndex == (int)MouseButtonMask.Left) && eventMouseButton.Pressed)
            {
                Input.MouseMode = Input.MouseModeEnum.Captured;
            }
        }
    }
}
