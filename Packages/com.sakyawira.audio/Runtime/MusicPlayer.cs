using System.Collections;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine;

namespace Sakyawira.Audio
{
    public class MusicPlayer : MonoBehaviour
    {
        [SerializeField]
        private List<AudioSource> _audioSources;
        private float _maxVolume = 0.52f;

        public void Start()
        {
            foreach(var audiosource in _audioSources)
            {
                audiosource.volume = 0;
                audiosource.loop = true;
            }
        }

        public void PlayMusic(int musicIndex)
        {
            FadeIn(musicIndex).Forget();
            for (int i = 0; i < _audioSources.Count; i++)
            {
                if (i != musicIndex)
                {
                    FadeOut(i).Forget();
                }
            }
        }

        public async UniTask FadeIn(int musicIndex)
        {
            while (_audioSources[musicIndex].volume < _maxVolume)
            {
                _audioSources[musicIndex].volume += 0.01f;
                await UniTask.Delay(50);
            }
        }

        public async UniTask FadeOut(int musicIndex)
        {
            while (_audioSources[musicIndex].volume != 0)
            {
                _audioSources[musicIndex].volume -= 0.01f;
                await UniTask.Delay(50);
            }
        }
    }
}
