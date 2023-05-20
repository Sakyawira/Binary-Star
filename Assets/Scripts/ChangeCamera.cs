using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class ChangeCamera : MonoBehaviour
{
    [SerializeField]
    private CinemachineVirtualCamera _startCamera;
    [SerializeField]
    private CinemachineVirtualCamera _endCamera;

    public void SwapCamera()
    {
        _startCamera.enabled = !_startCamera.enabled;
        _endCamera.enabled = !_endCamera.enabled;
    }
}
