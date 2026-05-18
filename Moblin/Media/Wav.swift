import Foundation

func createWav(sampleRate: Int, samples: [[Int16]]) -> Data? {
    let numberOfChannels = samples.count
    let bitsPerSample = 16
    let bytesPerSample = bitsPerSample / 8
    let blockAlign = numberOfChannels * bytesPerSample
    let dataSize: UInt32
    switch numberOfChannels {
    case 1:
        dataSize = UInt32(samples[0].count * bytesPerSample)
    case 2:
        guard samples[0].count == samples[1].count else {
            return nil
        }
        dataSize = UInt32(samples[0].count * bytesPerSample * numberOfChannels)
    default:
        return nil
    }
    let writer = ByteWriter()
    writer.writeUTF8Bytes("RIFF")
    writer.writeUInt32Le(44 - 8 + dataSize)
    writer.writeUTF8Bytes("WAVE")
    writer.writeUTF8Bytes("fmt ")
    writer.writeUInt32Le(16)
    writer.writeUInt16Le(1) // int16
    writer.writeUInt16Le(UInt16(numberOfChannels))
    writer.writeUInt32Le(UInt32(sampleRate))
    writer.writeUInt32Le(UInt32(sampleRate * blockAlign))
    writer.writeUInt16Le(UInt16(blockAlign))
    writer.writeUInt16Le(UInt16(bitsPerSample))
    writer.writeUTF8Bytes("data")
    writer.writeUInt32Le(dataSize)
    switch numberOfChannels {
    case 1:
        for sample in samples[0] {
            writer.writeUInt16Le(UInt16(bitPattern: sample))
        }
    case 2:
        for (sampleRight, sampleLeft) in zip(samples[0], samples[1]) {
            writer.writeUInt16Le(UInt16(bitPattern: sampleRight))
            writer.writeUInt16Le(UInt16(bitPattern: sampleLeft))
        }
    default:
        return nil
    }
    return writer.data
}
