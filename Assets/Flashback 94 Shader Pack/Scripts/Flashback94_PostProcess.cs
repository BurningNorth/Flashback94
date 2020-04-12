
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// Post-process script for scaling the framebuffer and quantizing colors                //
// Only for use with the 'Hidden/Flashback 94/Color Quantize' shader                    //
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
[AddComponentMenu("Flashback 94/Post Process")]
public class Flashback94_PostProcess : MonoBehaviour
{
    // Shader to use for color processing
    public Shader colorShader = null;

    // Runtime material generated from the above shader
    private Material colorMaterial = null;

    // Bits per color channel
    public int bitsPerChannel = 8;

    // Enumeration for the type of downsampling
    public enum DownsampleType { NONE, RELATIVE, ABSOLUTE };
    public DownsampleType downsampling = DownsampleType.NONE;

    // Scaling amount for relative downsampling
    public int downsampleRelativeAmount = 2;

    // Width and height for absolute downsampling
    public int downsampleAbsoluteWidth = 320;
    public int downsampleAbsoluteHeight = 240;

    // Enable/disable antialiasing when blitting
    public bool downsampleAntialiasing = true;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Disable this component if the resource check fails
        if (!CheckResources())
        {
            enabled = false;
            return;
        }

        // Set the number of color steps in the shader
        colorMaterial.SetFloat("_ColorSteps", Mathf.Pow(2f, bitsPerChannel));

        // Width and height for the buffer texture
        var bufWidth = source.width;
        var bufHeight = source.height;

        // Switch statement for downsampling methods
        switch (downsampling)
        {
            case DownsampleType.NONE:
                // Blit directly through the color material and exit
                Graphics.Blit(source, destination, colorMaterial);
                return;

            case DownsampleType.RELATIVE:
                // Scale render texture by relative amount
                bufWidth /= downsampleRelativeAmount;
                bufHeight /= downsampleRelativeAmount;
                break;

            case DownsampleType.ABSOLUTE:
                // Set render texture dimensions
                bufWidth = downsampleAbsoluteWidth;
                bufHeight = downsampleAbsoluteHeight;
                break;
        }

        // Create a temporary buffer and filter it by point
        var buffer = RenderTexture.GetTemporary(bufWidth, bufHeight, 0);
        buffer.filterMode = FilterMode.Point;

        // Set the filtering mode of the source texture before resizing
        source.filterMode = downsampleAntialiasing ? FilterMode.Bilinear : FilterMode.Point;

        // Blit into the resized render texture through the color material
        Graphics.BlitMultiTap(source, buffer, colorMaterial,
            new Vector2(-1f, -1f),
            new Vector2(-1f, 1f),
            new Vector2(1f, 1f),
            new Vector2(1f, -1f)
            );

        // Blit the result to the screen and release the buffer
        Graphics.Blit(buffer, destination);
        RenderTexture.ReleaseTemporary(buffer);
    }

    void OnDestroy()
    {
        // Destroy the material
        if (colorMaterial != null) DestroyImmediate(colorMaterial);
    }

    bool CheckResources()
    {
        // Check the shader
        if (colorShader == null)
        {
            Debug.LogWarning("<color=yellow>FLASHBACK '94 WARNING:</color> There is no shader attached to the post process!");
            return false;
        }

        // Check if the shader is supported
        if (!colorShader.isSupported)
        {
            Debug.LogWarning("<color=yellow>FLASHBACK '94 WARNING:</color> The shader '" + colorShader.name + "' is not supported on this platform!");
            return false;
        }

        // Check if the platform supports image effects
        if (!SystemInfo.supportsImageEffects)
        {
            Debug.LogWarning("<color=yellow>FLASHBACK '94 WARNING:</color> Image effects are not supported on this platform!");
            return false;
        }

        // Create the material if it doesn't exist
        if (colorMaterial == null)
        {
            colorMaterial = new Material(colorShader);
            colorMaterial.hideFlags = HideFlags.DontSave;
        }

        return true;
    }
}
