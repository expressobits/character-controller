using System;
using Godot;
using Godot.Collections;

// Script that plays sounds based on player actions.
// Using an [AudioInteract] array synchronized with physic_materials array to 
// identify different sound structures for each type of physical material.

public partial class PlayerAudios3D : Node3D
{
    // Default audio interact used
    [Export] public AudioInteract AudioInteract;
    // List of [PhysicsMaterial] synchronized with the [AudioInteract] list 
    [Export] public Array<PhysicsMaterial> PhysicMaterials = new Array<PhysicsMaterial>();
    // List of [AudioInteract] synchronized with the [PhysicsMaterial] list
    [Export] public Array<AudioInteract> AudioInteracts = new Array<AudioInteract>();
    // Specific case of audio interact that occurs when we are in the water
    [Export] public AudioInteract WaterAudioInteract;

    private AudioStreamPlayer3D _stepStream;
    private AudioStreamPlayer3D _landStream;
    private AudioStreamPlayer3D _jumpStream;
    private AudioStreamPlayer3D _crouchStream;
    private AudioStreamPlayer3D _uncrouchStream;
    private RayCast3D _raycast;
    private CharacterBody3D _characterBody;
    private CharacterController3D _characterController;

    public override void _Ready()
    {
        base._Ready();

        _stepStream = GetNode<AudioStreamPlayer3D>("Step");
        _landStream = GetNode<AudioStreamPlayer3D>("Land");
        _jumpStream = GetNode<AudioStreamPlayer3D>("Jump");
        _crouchStream = GetNode<AudioStreamPlayer3D>("Crouch");
        _uncrouchStream = GetNode<AudioStreamPlayer3D>("Uncrouch");
        _raycast = GetNode<RayCast3D>("Detect Ground");
        _characterBody = GetNode<CharacterBody3D>("..");
        _characterController = GetNode<CharacterController3D>("..");

        _characterController.Stepped += OnControllerStepped;
        _characterController.Crouched += OnControllerCrouched;
        _characterController.Jumped += OnControllerJumped;
        _characterController.Landed += OnControllerLanded;
        _characterController.Uncrouched += OnControllerUncrouched;
        _characterController.EnteredTheWater += OnControllerEnteredTheWater;
        _characterController.ExitTheWater += OnControllerExitTheWater;
    }

    private void OnControllerJumped()
    {
        _jumpStream.Stream = AudioInteract.JumpAudio;
        _jumpStream.Play();
    }

    private void OnControllerLanded()
    {
        GetAudioInteract();
        _landStream.Stream = AudioInteract.LandedAudio;
        _landStream.Play();
    }

    private void OnControllerStepped()
    {
        var collision = _raycast.GetCollider();
        GetAudioInteractOfObject(collision);
        _stepStream.Stream = AudioInteract.RandomStep();
        _stepStream.Play();
    }

    private void GetAudioInteract()
    {
        var kCol = _characterBody.GetLastSlideCollision();
        var collision = kCol.GetCollider(0);
        GetAudioInteractOfObject(collision);
    }

    private void GetAudioInteractOfObject(GodotObject collision)
    {
        if (_characterController.IsOnWater())
        {
            AudioInteract = WaterAudioInteract;
            return;
        }
        if (collision == null)
        {
            return;
        }

        if (!collision.HasMethod("get_physics_material_override"))
        {
            return;
        }

        var mat = (PhysicsMaterial)collision.Call("get_physics_material_override");

        if (mat != null)
        {
            int i = PhysicMaterials.IndexOf(mat);
            if (i != -1)
            {
                AudioInteract = AudioInteracts[i];
            }
        }
    }

    private void OnControllerCrouched()
    {
        _crouchStream.Play();
    }

    private void OnControllerUncrouched()
    {
        _uncrouchStream.Play();
    }

    private void OnControllerEnteredTheWater()
    {
        AudioInteract = WaterAudioInteract;
        _landStream.Stream = AudioInteract.LandedAudio;
        _landStream.Play();
    }

    private void OnControllerExitTheWater()
    {
        _jumpStream.Stream = AudioInteract.JumpAudio;
        _jumpStream.Play();
    }
}
