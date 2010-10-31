﻿package tuio.osc {		import flash.utils.ByteArray;		/**	 * An OSCBundle	 * @author Immanuel Bauer	 */	public class OSCBundle extends OSCPacket {				private var contentBytes:ByteArray;		private var content:Array;				private var time:OSCTimetag;				private const SECONDS_1900_1970:uint = 2208988800;				/**		 * Creates a OSCBundle from the given ByteArray containing binary coded OSCBundle		 * 		 * @param	bytes ByteArray containing OSC data		 */		public function OSCBundle(bytes:ByteArray) {			super(bytes);						if(bytes != null){							//skip the OSC Bundle head				this.bytes.readUTFBytes(8);								//get OSC timetag				this.time = this.readTimetag();								//copy remaining bytes to a new ByteArray				//this.contentBytes = new ByteArray();				//this.bytes.readBytes(this.contentBytes, 0, this.bytes.bytesAvailable);				this.content = new Array();								//parse the contentBytes to get the OSC Bundles subbundles or messages				getSubPackets();							} else {				this.bytes = new ByteArray();				this.writeString("#bundle");				this.content = [];			}		}				/**		 * Returns the subpacket of this OSCPacket with the specified index		 * 		 * @param	pos The index of the subpacket		 * @return An OSCPacket if the given index is valid, else null		 */		public function getContent(pos:uint):OSCPacket {			if(pos < content.length){				return content[pos];			} else {				return null;			}		}			/**		 * Returns all subpackets of this OSCBundle		 * 		 * @return An Array containing OSCPackets		 */		public function get subPackets():Array {			return this.content;		}				/**		 * Returns the number of subpackets in this OSCBundle		 * 		 * @return The number of subpackets		 */		public function get subPacketCount():uint {			return this.content.length;		}				/**		 * Parses the contentBytes for additional OSCBundles or OSCMessages within this OSCBundle		 */		private function getSubPackets():void {			var blockLength:int;			while (this.bytes.bytesAvailable > 0) {				blockLength = this.bytes.readInt();				//var cBytes:ByteArray = new ByteArray();				//this.contentBytes.readBytes(cBytes, 0, blockLength);								if (isBundle(this.bytes)) {					this.content.push(new OSCBundle(this.bytes));				} else {					this.content.push(new OSCMessage(this.bytes));				}			}		}				/**		 * Adds an <code>OSCPacket</code> to the <code>OSCBundle</code>		 * 		 * @param	packet The <code>OSCPacket</code> to be added.		 */		public function addPacket(packet:OSCPacket):void {			this.content.push(packet);			this.bytes.writeInt(packet.bytes.length);			packet.bytes.position = 0;			packet.bytes.readBytes(this.bytes, this.bytes.position, packet.bytes.length);		}				/**		 * @return The OSCTimetag of this OSCBundle		 */		public function get timetag():OSCTimetag {			return this.time;		}				/**		 * Set the OSCBundles OSCTimetag		 */		public function set timetag(ott:OSCTimetag):void {			this.time = ott;			this.bytes.position = 0;			this.writeTimetag(ott);			this.bytes.position = this.bytes.length - 1;		}				/**		 * Generates a String representation of this OSCBundle and its subpackets for debugging purposes		 * 		 * @return traceable String		 */		public override function getPacketInfo():String {			var out:String = new String();			out += "\nSeconds: " + this.timetag.seconds.toString();			out += "\nPicoseconds: " + this.timetag.picoseconds.toString();			out += "\nSubPackets: " + this.subPacketCount.toString();			for each(var item:OSCPacket in content) {				out += item.getPacketInfo();			}			return out;		}				/**		 * Checks if the given ByteArray is an OSCBundle		 * 		 * @param	bytes The ByteArray to be checked.		 * @return true if the ByteArray contains an OSCBundle		 */		public static function isBundle(bytes:ByteArray):Boolean {			if (bytes != null) {				if (bytes.bytesAvailable >= 8) {					//bytes.position = 0;					var header:String = bytes.readUTFBytes(8);					bytes.position -= 8;					if (header == "#bundle") {						return true;					} else {						return false;					}				} else {					return false;				}			} else {				return false;			}		}			}	}