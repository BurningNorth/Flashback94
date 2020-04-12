
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// Custom editor for the 'Flashback94_PostProcess' script                               //
// Must be kept in 'Editor' or one of its subdirectories                                //
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Flashback94_PostProcess))]
public class Flashback94_PostProcess_Editor : Editor
{
    private SerializedProperty
        colorShader,
        bitsPerChannel,
        downsampling,
        downsampleRelativeAmount,
        downsampleAbsoluteWidth,
        downsampleAbsoluteHeight,
        downsampleAntialiasing;

    public void OnEnable()
    {
        // Find all serialized properties
        colorShader = serializedObject.FindProperty("colorShader");
        bitsPerChannel = serializedObject.FindProperty("bitsPerChannel");
        downsampling = serializedObject.FindProperty("downsampling");
        downsampleRelativeAmount = serializedObject.FindProperty("downsampleRelativeAmount");
        downsampleAbsoluteWidth = serializedObject.FindProperty("downsampleAbsoluteWidth");
        downsampleAbsoluteHeight = serializedObject.FindProperty("downsampleAbsoluteHeight");
        downsampleAntialiasing = serializedObject.FindProperty("downsampleAntialiasing");
    }

    public override void OnInspectorGUI()
    {
        // Update the serialized object
        serializedObject.Update();

        // Set the color shader from a source file
        colorShader.objectReferenceValue = EditorGUILayout.ObjectField("Color Shader", colorShader.objectReferenceValue, typeof(Shader), false) as Shader;

        // Set the bit depth of the color shader between 1 and 8
        bitsPerChannel.intValue = EditorGUILayout.IntSlider("Bits Per Color Channel", bitsPerChannel.intValue, 1, 8);

        // Set the downsampling type
        downsampling.enumValueIndex = EditorGUILayout.Popup("Downsampling Type", downsampling.enumValueIndex, downsampling.enumNames);

        // Expose different properties depending on the downsampling type
        switch (downsampling.enumNames[downsampling.enumValueIndex])
        {
            case "NONE":
                // Expose no variables if we're not downsampling
                break;

            case "RELATIVE":
                // Relative downsampling divides the framebuffer by a positive integer between 1 and 32
                downsampleRelativeAmount.intValue = EditorGUILayout.IntSlider("Downsampling Relative Amount", downsampleRelativeAmount.intValue, 1, 32);
                downsampleAntialiasing.boolValue = EditorGUILayout.Toggle("Enable Antialiasing", downsampleAntialiasing.boolValue);
                break;

            case "ABSOLUTE":
                // Absolute downsampling scales the framebuffer to a fixed size between 32x32 and 1920x1920
                downsampleAbsoluteWidth.intValue = EditorGUILayout.IntSlider("Downsampling Absolute Width", downsampleAbsoluteWidth.intValue, 32, 1920);
                downsampleAbsoluteHeight.intValue = EditorGUILayout.IntSlider("Downsampling Absolute Height", downsampleAbsoluteHeight.intValue, 32, 1920);
                downsampleAntialiasing.boolValue = EditorGUILayout.Toggle("Enable Antialiasing", downsampleAntialiasing.boolValue);
                break;
        }

        // Apply property modifications
        serializedObject.ApplyModifiedProperties();
    }
}
