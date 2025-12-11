class HashMapEntry {
    property key
    property hash
    property value
}

export class HashMap {
    private property bins_count
    private property bins

    func constructor {
        self.bins_count = 128
        self.bins = List.create_with(self.bins_count, ->[])
    }

    func set(key, value) {
        assert key instanceof String
        const hash = self.key_to_hash(key)
        const bin_index = self.hash_to_bin_index(hash)
        const bin = self.bins[bin_index]

        const entry = bin.findBy(->(entry) entry.hash == hash)
        if entry instanceof HashMapEntry {
            assert entry.hash == hash
            entry.value = value
            return self
        }

        bin.push(HashMapEntry(key, hash, value))
        self
    }

    func set_if_not_exist(key, value) {
        assert key instanceof String
        if !self.contains(key) self.set(key, value)
    }

    func at(key) {
        assert key instanceof String
        const hash = self.key_to_hash(key)
        const bin_index = self.hash_to_bin_index(hash)
        const bin = self.bins[bin_index]
        const entry = bin.findBy(->(entry) entry.hash == hash)
        if entry == null return null
        entry.value
    }

    func contains(key) {
        assert key instanceof String
        const hash = self.key_to_hash(key)
        const bin_index = self.hash_to_bin_index(hash)
        const bin = self.bins[bin_index]
        bin.findBy(->(entry) entry.hash == hash) != null
    }

    func remove(key) {
        assert key instanceof String
        const hash = self.key_to_hash(key)
        const bin_index = self.hash_to_bin_index(hash)
        const bin = self.bins[bin_index]
        const old_length = bin.length
        self.bins[bin_index] = self.bins.filter(->(entry) entry.hash != hash)
        self.bins[bin_index].length != old_length
    }

    func entries = self.bins.flatten()
    func keys = self.entries().map(->(entry) entry.key)
    func values = self.entries().map(->(entry) entry.value)
    func each(...args) = self.entries().each(...args)
    func map(...args) = self.entries().map(...args)
    func size() = self.entries().length

    private func key_to_hash(key) = key.hashcode
    private func hash_to_bin_index(hash) = hash % self.bins_count
}
