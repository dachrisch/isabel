/*
 * ISABEL: A group collaboration tool for the Internet
 * Copyright (C) 2009 Agora System S.A.
 * 
 * This file is part of Isabel.
 * 
 * Isabel is free software: you can redistribute it and/or modify
 * it under the terms of the Affero GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Isabel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Affero GNU General Public License for more details.
 * 
 * You should have received a copy of the Affero GNU General Public License
 * along with Isabel.  If not, see <http://www.gnu.org/licenses/>.
 */
package isabel.seco.tests.test2;

import isabel.seco.network.javaser.*;

public class SumaMsg implements JavaMessage {
	public int s1;

	public int s2, senderId;
	public String grupo, senderName;

	public SumaMsg(String grupo, int s1, int s2, String senderId, String senderName) {
		this.s1 = s1;
		this.s2 = s2;
		this.grupo = grupo;
		this.senderName = senderName;
		this.senderId = Integer.parseInt(senderId);
	} 
	
	public String toString(){
		String suma = s1+ "+" +s2;
		return suma;
	}

}
