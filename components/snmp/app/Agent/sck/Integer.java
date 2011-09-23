// -----------------------Integer.java
// Copyright (C) 1998  Yves Soun.

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

/** Integer (tag: 0x02)
 *  <P>An Integer has a sign and a length less or equal to 4 bytes.
 *  <P><B>Note:</B> be careful of naming conflicts between <B>java.lang.Integer</B> and <B>sck.Integer</B>.
 */
public class Integer extends smi { 
  
  private int valeur  ;

  /** Builds an Integer from an int.
   */
  public Integer(int valeur){
    super(smi.INTEGER_tag);
    this.valeur = valeur;
  }

  /** Builds an Integer from a String. 
   *  <BR>If v == null then Integer(0).
   *  @exception InvalidObjectException is thrown if an Integer
   *  can't be build from the String.
   *  @see java.lang.Integer#valueOf(java.lang.String)
   */
  public Integer(String v) throws InvalidObjectException{
    super(smi.INTEGER_tag);
    try{
    if ( v == null)
     valeur = 0;
    else
     valeur = java.lang.Integer.valueOf(v).intValue();
    } catch (Exception e) {
      throw new InvalidObjectException("Integer.valueOf( " + v + ") : illegal !");
    }
  }
	
  /** Builds an Integer from a ByteArrayInputStream holding an Integer Ber coding. 
   *  <BR>Bytes read are removed from the stream.
   *  <P><B>Note:</B> The ByteArrayInputStream must not contain the Integer Tag.
   *  @exception IOException is thrown if a problem occurs while trying to decode the stream.
   */
  public Integer(ByteArrayInputStream inBer) throws IOException{
    super(smi.INTEGER_tag);
    decodeBer(inBer);
  }

  /** Compares two Integers for equality.
   *  @return true if this Integer is the same as the obj argument, false otherwise.
   */
  public boolean equals (Object obj) {
    if (this == obj)
      return true;
    if (!super.equals(obj))
      return false;
    if (this.valeur == ((Integer)obj).valeur)
      return true;
    return false;
    }

  /** Returns the value of this Integer as a String.
   */  
  public String toString(){
    return (String.valueOf(this.valeur));
  }

  /** Returns Ber coding of this Integer
   *  Used by smi.CodeBer().
   */
  byte[] codeValeur(){
    int entier = this.valeur;
    int taille = 4; // taille de l'entier.
    int mask=0xFF800000;

    // On tronque les octets inutiles c.a.d quand les 9 premiers octets sont
    // identiques, on supprime les huits premiers octets qui "prolongent" le signe (0x00 ou 0xFF)
    while((((entier & mask) == 0) || ((entier & mask) == mask)) && taille > 1){
	taille--;
	entier <<= 8;
    }
    byte b[] = new byte[taille];
    entier = this.valeur;
    for (int i=--taille; i>=0; i--){
      b[i] = (byte) entier ;
      entier >>=8;
    }
  return (b);
  }
  
  /** Used by smi.decodeBer().
   */
  void decodeValeur(ByteArrayInputStream bufferBer, int lgBerValeur) throws IOException{

    if (lgBerValeur > 4) 
      throw new IOException(" longueur >4 ! ");

    int b = bufferBer.read(); // b: de 0 a 255.
    // y-a-t-il un bit de signe ?
    if ( b > 0x7F) {
      valeur = ( 0xFFFFFFFF << 8 ) | b; // bit de signe
    } else {
      valeur = b;
    }
    while (--lgBerValeur >0 ) 
      valeur = (valeur << 8) | bufferBer.read(); 
  }
}
