List<T> insertedAfter<T>(List<T> source, int index, List<T> values) { final copy = List<T>.from(source); copy.insertAll(index + 1, values); return copy; }
