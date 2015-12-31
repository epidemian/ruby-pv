require 'pv'

RSpec.describe 'pv' do
  it 'is defined for all Enumerables' do
    expect(Enumerable.public_method_defined?(:pv)).to be true
  end

  it 'returns an Enumerable' do
    expect([].pv).to be_an Enumerable
  end

  it 'delegates to the original Enumerable' do
    nums = (1..5).pv.select(&:odd?)
    expect(nums).to eq [1, 3, 5]
  end

  it 'works for iterator methods that receive multiple-argument blocks' do
    pairs = {a: 1, b: 2}.pv.map { |k, v| "#{k}:#{v}" }
    expect(pairs).to eq %w[a:1 b:2]
  end

  it 'works on Enumerators of unknown size' do
    daft_punk_lyrics = Enumerator.new do |y|
      loop { y << 'Around the world' }
    end
    expect(daft_punk_lyrics.size).to be_nil # nil = unknown

    verse = daft_punk_lyrics.pv.take(8)

    expect(verse).to eq ['Around the world', 'Around the world'] * 4
  end

  it 'works on Enumerators of infinite size' do
    ballmer = ['developers'].cycle
    expect(ballmer.size).to be_infinite

    chant = ballmer.pv.take(4)

    expect(chant).to eq %w[developers developers developers developers]
  end

  it 'can receive a block' do
    nums = []
    5.times.pv do |n|
      nums << n
    end
    expect(nums).to eq [0, 1, 2, 3, 4]
  end

  it 'returns the original method return value when called with a block' do
    evens = (1..7).select.pv(&:even?)
    expect(evens).to eq [2, 4, 6]
  end
end
