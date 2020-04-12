using UnityEngine;

namespace Flashback94ExampleScene
{
    public class Turntable : MonoBehaviour
    {
        void Update()
        {
            var pos = transform.position;
            pos.y = -0.5f + Mathf.Sin(Time.timeSinceLevelLoad * 2f) * 0.25f;
            transform.position = pos;

            if (Input.GetKey(KeyCode.Mouse0))
                transform.Rotate(0f, Input.GetAxis("Mouse X") * -200f * Time.deltaTime, 0f);
        }
    }
}
