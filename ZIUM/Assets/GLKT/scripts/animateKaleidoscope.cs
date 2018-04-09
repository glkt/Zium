using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class animateKaleidoscope : MonoBehaviour {

	public Transform[] kaleiPieces;

	private Vector3 position;
	private Vector3 targetPosition;
	private Quaternion rot;
	private Quaternion targetRot;

	public float t;

	public float speed;

	void Update () {

		t += Time.deltaTime * speed;

		position = Vector3.Lerp(position,targetPosition,Mathf.SmoothStep(0,1,t*speed));
		rot = Quaternion.Slerp(rot,targetRot,Mathf.SmoothStep(0,1,t*speed));

		foreach(Transform t in kaleiPieces){
			t.localPosition = position;
			t.localRotation = rot;
			t.gameObject.GetComponent<Renderer>().material.SetTextureOffset("_MainTex", new Vector2(Time.time*0.002f, 0));
		}

		if(t>1.2f){		
			rot = targetRot;
			position = targetPosition;
			targetRot = Random.rotation;
			targetPosition = new Vector3(Random.Range(-0.3f,0.3f),Random.Range(-0.2f,0.2f),Random.Range(-0.3f,0.3f));
			t = 0;
		}
	}
}
