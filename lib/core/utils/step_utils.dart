int safeStepIndex(int index, int max) { if (max <= 0) return 0; if (index < 0) return 0; if (index >= max) return max - 1; return index; }
