require 'hash_diff'

describe HashDiff do
  let(:hash1) { { same: 1, different: 2, old: 3, value_to_hash: 3, same_hash: {a: 3, b: 4}, different_hash: { same: 1, different: 2, old: 3 } } }
  let(:hash2) { { same: 1, different: 'x', new: 5, value_to_hash: {a: 4}, same_hash: {a: 3, b: 4}, different_hash: { same: 1, different: 3, new: 4 }, new_hash: { blah: 44 } } }

  context 'Diff' do
    attr_reader :diff

    before :each do
      @diff = HashDiff.diff hash1, hash2
    end

    it 'adds new keys to __added__ key' do
      expect(diff['__added__']).to eq [:new, :new_hash]
    end

    it 'adds keys to __deleted__ key' do
      expect(diff['__deleted__']).to eq [:old]
    end

    it 'has different keys' do
      expect(diff[:different]).to eq 'x'
    end

    it "doesn't have same keys" do
      expect(diff.has_key?(:same)).to eq false
    end

    describe 'Patch' do
      context 'Valid' do
        attr_reader :patched_hash

        before :each do
          @patched_hash = HashDiff.patch! hash1, diff
        end

        it "creates modified array from original and hash" do
          expect(patched_hash).to eq hash2
        end
      end

      context 'Invalid' do
        let(:hash) { { a: 1, b: 2 } }

        it 'complains if __added__ keys don\'t exist in patch' do
          patch = { '__added__' => [:c] }

          expect { HashDiff.patch!(hash, patch) }.to raise_exception
        end

        it 'complains if __added__ keys exist in original' do
          patch = { '__added__' => [:b] }

          expect { HashDiff.patch!(hash, patch) }.to raise_exception
        end

        it 'complains if new key doesn\'t exist in __added__ array' do
          skip "Whatever, I don't care about it right now"

          patch = { new: 35 }

          expect { HashDiff.patch!(hash, patch) }.to raise_exception
        end

        it 'complains if __deleted__ keys don\'t exist in original' do
          patch = { '__deleted__' => [:c] }

          expect { HashDiff.patch!(hash, patch) }.to raise_exception
        end

        it 'complains if __deleted__ keys exists in patch' do
          patch = { '__deleted__' => [:b], b: 4 }

          expect { HashDiff.patch!(hash, patch) }.to raise_exception
        end
      end
    end
  end
end
