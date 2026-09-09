public with sharing class StrideDepCaller {
    // References StrideDepHelper. Promote this one ALONE and the gate should name StrideDepHelper.
    public static String run() {
        return StrideDepHelper.greet();
    }
}