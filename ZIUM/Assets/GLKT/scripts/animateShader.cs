using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class animateShader : MonoBehaviour {

	private float offset;
	public float speed = 0.1f;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		offset += Time.deltaTime*speed;
		Shader.SetGlobalFloat("_worldOffset",offset);
	}
}
