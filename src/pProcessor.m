classdef PacketProcessor
    properties
        hidDevice;
    end
    methods
        function packet = PacketProcessor(device)
            javaaddpath('../lib/hid4java-0.5.0.jar');

            import org.hid4java.*;
            import org.hid4java.event.*;
            import java.nio.ByteBuffer;
            import java.nio.ByteOrder;
            import java.lang.*;
            
            if nargin > 0
                packet.HidDevice = device;
            end
        end
        function com = command(idOfCommand, values)
            packetSize = 64;
            numFloats = (packetSize / 4) - 1;
            message = javaArray('java.lang.Byte', packetSize);
            be = java.nio.ByteOrder.LITTLE_ENDIAN;
            java.nio.ByteBuffer.wrap(message).order(be).putInt(0, idOfCommand).array();
            
            loopI = 0;
            
            while loopI < numFloats && loopI < len(values)
                baseIndex = (4 * loopI) + 4;
                java.nio.ByteBuffer.wrap(message).order(be).putFloat(baseIndex, values(loopI)).array();
                loopI = loopI + 1;
            end
            
            returnValues = zeros(numFloats);
            val = packet.hidDevice.write(message, packetSize, 0);
            if val > 0
                read = packet.hidDevice.read(message, 1000);
                if read > 0
                    for i=1:len(numFloats)
                        baseIndex = (4 * i) + 4;
                        returnValues(i) = java.nio.ByteBuffer.wrap(message).order(be).getFloat(baseIndex);
                    end
                else
                    disp("Read failed")
                end
            else
                disp("Writing failed")
            end
            com = returnValues;
        end
    end
end
