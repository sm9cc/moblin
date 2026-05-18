import Foundation

let srtControlPacketTypeBit: UInt16 = 0x8000
let srtControlTypeSize = 2
let srtSequenceNumberSize = 4
let srtNakMaximumSequenceNumbers = 1300 / 4

enum SrtPacketType: UInt16 {
    case handshake = 0x0000
    case keepAlive = 0x0001
    case ack = 0x0002
    case nak = 0x0003
    case congestionWarning = 0x0004
    case shutdown = 0x0005
    case ackAck = 0x0006
    case dropReq = 0x0007
    case peerError = 0x0008
}

func isSrtDataPacket(packet: Data) -> Bool {
    packet.count >= srtSequenceNumberSize && (packet[0] & 0x80) == 0
}

func getSrtControlPacketType(packet: Data) -> UInt16 {
    packet.getUInt16Be() & 0x7FFF
}

func getSrtSequenceNumber(packet: Data) -> UInt32 {
    packet.getUInt32Be()
}

func isSrtSnAcked(sn: UInt32, ackSn: UInt32) -> Bool {
    if sn < ackSn {
        ackSn - sn < 100_000_000
    } else {
        sn - ackSn > 100_000_000
    }
}

func isSrtSnRange(sn: UInt32) -> Bool {
    (sn & 0x8000_0000) == 0x8000_0000
}

func processSrtNak(packet: Data, onNak: (UInt32) -> Void) {
    var offset = 16
    var sequenceNumbers = 0
    func processSn(_ sn: UInt32) -> Bool {
        guard sequenceNumbers < srtNakMaximumSequenceNumbers else {
            return false
        }
        onNak(sn)
        sequenceNumbers += 1
        return true
    }
    while offset <= packet.count - 4 {
        let nakSn = packet.getUInt32Be(offset: offset)
        offset += 4
        if isSrtSnRange(sn: nakSn) {
            guard offset <= packet.count - 4 else {
                return
            }
            let upToNakSn = packet.getUInt32Be(offset: offset)
            var sn = nakSn & 0x7FFF_FFFF
            while sn <= upToNakSn {
                guard processSn(sn) else {
                    return
                }
                if sn == upToNakSn {
                    break
                }
                sn += 1
            }
            offset += 4
        } else {
            guard processSn(nakSn) else {
                return
            }
        }
    }
}
