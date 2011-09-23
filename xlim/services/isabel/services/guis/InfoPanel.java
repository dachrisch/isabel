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
/*
 * InfoPanel.java
 *
 * Created on 7 de septiembre de 2004, 15:38
 */

package services.isabel.services.guis;

import javax.swing.*;
import java.util.LinkedList;
import xedl.lib.xedl.*;

/**
 *
 * @author  alvaro
 */
public class InfoPanel extends javax.swing.JPanel {
    
    protected XEDL xedl;
    
    /** Creates new form InfoPanel */
    public InfoPanel(XEDL xedl) {
        this.xedl=xedl;
        initComponents();
    }
    
    public InfoPanel(){
        this.xedl=null;
    }
    
    public void setData(XEDL xedl) {
        this.xedl=xedl;
        initComponents();
    }
    
    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    private void initComponents() {//GEN-BEGIN:initComponents
        java.awt.GridBagConstraints gridBagConstraints;

        setLayout(new java.awt.BorderLayout());

    }//GEN-END:initComponents
    
    
    // Variables declaration - do not modify//GEN-BEGIN:variables
    // End of variables declaration//GEN-END:variables
    
}
