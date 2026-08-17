global with sharing class StrideWaveERemote implements Callable {
    // Referenced by the Stride_WaveE_English OmniScript as its remoteClass — the dependency Wave E is about.
    global Object call(String action, Map<String, Object> args) {
        return new Map<String, Object>{ 'marker' => 'wave-e' };
    }
}