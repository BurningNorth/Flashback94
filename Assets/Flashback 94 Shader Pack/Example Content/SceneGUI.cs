using UnityEngine;

namespace Flashback94ExampleScene
{
    public class SceneGUI : MonoBehaviour
    {
        public Material cubeDiff;
        public Material cubeSpec;
        public Material cubeUnlit;

        public Material cutoutDiff;
        public Material cutoutSpec;
        public Material cutoutUnlit;

        public Material opaqueDiff;
        public Material opaqueSpec;
        public Material opaqueUnlit;

        public Material rimDiff;
        public Material rimSpec;
        public Material rimUnlit;

        public Material transDiff;
        public Material transSpec;
        public Material transUnlit;

        private Renderer cube;
        private Renderer capsule;
        private Renderer sphere;

        void Start()
        {
            cube = GameObject.Find("Cube").GetComponent<Renderer>();
            capsule = GameObject.Find("Capsule").GetComponent<Renderer>();
            sphere = GameObject.Find("Sphere").GetComponent<Renderer>();

            MaterialOpaque();
        }

        public void MaterialCubemap()
        {
            cube.material = cubeDiff;
            capsule.material = cubeSpec;
            sphere.material = cubeUnlit;
        }

        public void MaterialCutout()
        {
            cube.material = cutoutDiff;
            capsule.material = cutoutSpec;
            sphere.material = cutoutUnlit;
        }

        public void MaterialOpaque()
        {
            cube.material = opaqueDiff;
            capsule.material = opaqueSpec;
            sphere.material = opaqueUnlit;
        }

        public void MaterialRimlight()
        {
            cube.material = rimDiff;
            capsule.material = rimSpec;
            sphere.material = rimUnlit;
        }

        public void MaterialTransparent()
        {
            cube.material = transDiff;
            capsule.material = transSpec;
            sphere.material = transUnlit;
        }
    }
}
