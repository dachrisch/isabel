//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.1.2-b01-fcs 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2007.02.14 at 02:11:19 PM CET 
//


package xedl.lib.jaxb;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="SESSION_PORT" type="{http://www.w3.org/2001/XMLSchema}anyType" minOccurs="0"/>
 *         &lt;element name="MASTER" type="{http://www.w3.org/2001/XMLSchema}anyType" minOccurs="0"/>
 *         &lt;element name="OPEN_SESSION" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="ALLOW_WATCHPOINTS" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="MAIL_ADDRESS" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIPTION" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="COMMENT" type="{http://www.w3.org/2001/XMLSchema}string" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element name="SITES" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "sessionport",
    "master",
    "opensession",
    "allowwatchpoints",
    "mailaddress",
    "description",
    "comment",
    "sites"
})
@XmlRootElement(name = "session-info")
public class SessionInfo {

    @XmlElement(name = "SESSION_PORT")
    protected Object sessionport;
    @XmlElement(name = "MASTER")
    protected Object master;
    @XmlElement(name = "OPEN_SESSION")
    protected Boolean opensession;
    @XmlElement(name = "ALLOW_WATCHPOINTS")
    protected Boolean allowwatchpoints;
    @XmlElement(name = "MAIL_ADDRESS")
    protected String mailaddress;
    @XmlElement(name = "DESCRIPTION")
    protected String description;
    @XmlElement(name = "COMMENT")
    protected List<String> comment;
    @XmlElement(name = "SITES")
    protected String sites;

    /**
     * Gets the value of the sessionport property.
     * 
     * @return
     *     possible object is
     *     {@link Object }
     *     
     */
    public Object getSESSIONPORT() {
        return sessionport;
    }

    /**
     * Sets the value of the sessionport property.
     * 
     * @param value
     *     allowed object is
     *     {@link Object }
     *     
     */
    public void setSESSIONPORT(Object value) {
        this.sessionport = value;
    }

    /**
     * Gets the value of the master property.
     * 
     * @return
     *     possible object is
     *     {@link Object }
     *     
     */
    public Object getMASTER() {
        return master;
    }

    /**
     * Sets the value of the master property.
     * 
     * @param value
     *     allowed object is
     *     {@link Object }
     *     
     */
    public void setMASTER(Object value) {
        this.master = value;
    }

    /**
     * Gets the value of the opensession property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOPENSESSION() {
        return opensession;
    }

    /**
     * Sets the value of the opensession property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOPENSESSION(Boolean value) {
        this.opensession = value;
    }

    /**
     * Gets the value of the allowwatchpoints property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isALLOWWATCHPOINTS() {
        return allowwatchpoints;
    }

    /**
     * Sets the value of the allowwatchpoints property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setALLOWWATCHPOINTS(Boolean value) {
        this.allowwatchpoints = value;
    }

    /**
     * Gets the value of the mailaddress property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMAILADDRESS() {
        return mailaddress;
    }

    /**
     * Sets the value of the mailaddress property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMAILADDRESS(String value) {
        this.mailaddress = value;
    }

    /**
     * Gets the value of the description property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIPTION() {
        return description;
    }

    /**
     * Sets the value of the description property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIPTION(String value) {
        this.description = value;
    }

    /**
     * Gets the value of the comment property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the comment property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCOMMENT().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    public List<String> getCOMMENT() {
        if (comment == null) {
            comment = new ArrayList<String>();
        }
        return this.comment;
    }
    
    /**
     * Method to get the first comment
     * @return
     */
    public String getFistCOMMENT() {
        if (comment == null) {
            return "";
        }
        return this.comment.get(0);
    }

    
    /**
     * Method to set the first comment
     * 
     */
    public void addCOMMENT(String commentary) {
        if (comment == null) {
        	 comment = new ArrayList<String>();
        }
        this.comment.add(commentary);
    }
    
    /**
     * Gets the value of the sites property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSITES() {
        return sites;
    }

    /**
     * Sets the value of the sites property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSITES(String value) {
        this.sites = value;
    }

}
