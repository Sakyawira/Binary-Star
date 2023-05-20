using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Sakyawira.Audio
{
    public class SoundPlayer : MonoBehaviour
    {
        [SerializeField]
        private AudioSource _audioSource;
        [SerializeField]
        private AudioClip _audioClip;

        public void PlaySound()
        {
            _audioSource.clip = _audioClip;
            _audioSource.loop = true;
            _audioSource.Play();
        }

        public void StopSound()
        {
            _audioSource.loop = false;
            _audioSource.Stop();
        }
    }
}
