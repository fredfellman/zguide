package ;
import haxe.io.Bytes;
import neko.Lib;
#if !php
import neko.Random;
#end

import org.zeromq.ZMQ;
import org.zeromq.ZMQSocket;
import org.zeromq.ZFrame;

/**
 * Helper class for example applications
 */

class ZHelpers 
{

	/**
	 * Receives all message parts from socket, prints neatly
	 * @param	socket
	 */
	public static function dump(socket:ZMQSocket) {
		var buf:StringBuf = new StringBuf();
		
		buf.add("----------------------------------------\n");
		
		while (true) {
			// Process all parts of the message
			var f = ZFrame.recvFrame(socket);
			if (f.hasData()) {
				buf.add("[" + StringTools.lpad(Std.string(f.size()), "0", 3) + "] ");
				// Dump message as text or binary
				var isText = true;
				for (i in 0...f.data.length) {
					if (f.data.get(i) < 32 || f.data.get(i) > 127) isText = false; 
				}
				if (isText)
					buf.add(f.toString()) ;
				else
					buf.add(f.strhex());
					
				buf.add("\n");
			}
			if (!f.more) break;
		}
		
		Lib.println(buf.toString());
		
	}
	
	/**
	 * Set simple random printable identity on socket
	 * @param	socket
	 */
	public static function setID(socket:ZMQSocket):String {

		var randNumber1, randNumber2:Int;
		
#if php
		randNumber1 = untyped __php__('rand(0, 0x10000)');
		randNumber2 = untyped __php__('rand(0, 0x10000)');
#else		
		var rnd = new Random();
		randNumber1 = rnd.int(0x10000);
		randNumber2 = rnd.int(0x10000);
#end
		
		var _id = StringTools.hex(randNumber1, 4) + "-" + StringTools.hex(randNumber2, 4);
		socket.setsockopt(ZMQ_IDENTITY, Bytes.ofString(_id));
		return _id;
	}
	
}