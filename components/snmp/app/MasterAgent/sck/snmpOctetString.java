
//----------------- snmpOctetString.java

// This program is free software; you can redistribute it and/or
// modify it under the terms of the Affero GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// Affero GNU General Public License for more details (cf. file COPYING).


package sck;

import java.io.*;

/** OctetString (tag: 0x04)
 *  <P>This is an ascii String.
 */
public class snmpOctetString extends smi { 
  
  private String valor  ;

  /** Builds an OctetString from a String
   */
  public snmpOctetString(String s){
    super(smi.OCTETSTRING_tag);
    this.valor = s;
  }

  /** Builds an OctetString from a ByteArrayInputStream holding an OctetString Ber coding. 
   *  <BR>Bytes read are removed from the stream.
   *  <P><B>Note:</B> The ByteArrayInputStream must not contain the OctetString Tag.
   *  @exception IOException is thrown if a problem occurs while trying to decode the stream.
   */
  public snmpOctetString(ByteArrayInputStream inBer) throws IOException{
    super(smi.OCTETSTRING_tag);
    decodeBer(inBer);
  }

  /** Compares two OctetStrings for equality.
   *  @return true if this OctetString is the same as the obj argument, false otherwise.
   */
  public boolean equals (Object obj) {
    if (this == obj)
      return true;
    if (!super.equals(obj))
      return false;
    if (this.valor.equals(((snmpOctetString)obj).valor))
      return true;
    return false;
    }

  /** Returns the value of this OctetString as a String.
   */  
  public String toString(){
    return (this.valor);
  }

  /** Returns Ber coding of this OctetString.
   *  Used by smi.CodeBer().
   */
  byte[] codeValor(){
    byte b[] = this.valor.getBytes(); // getBytes (ISO-Latin-1) por defecto
    return b;
  }
  
  /** Used by smi.decodeBer().
   */
  void decodeValor(ByteArrayInputStream bufferBer, int lgBervalor) throws IOException{
    if ( lgBervalor != 0) {
      byte b[] = new byte[lgBervalor];
      int taille = bufferBer.read(b,0,lgBervalor);
      if (taille < lgBervalor )
        throw new IOException(" End of Stream. Can't read "+ lgBervalor +" bytes");
      this.valor = new String(b); // ascii (ISO-Latin-1 ?) vers Unicode 1- bits.
    }else{
      this.valor = new String("");
    }
  }
}