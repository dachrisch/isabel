//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.1.2-b01-fcs 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2007.02.14 at 02:11:19 PM CET 
//


package xedl.lib.jaxb;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for isdn_role_type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="isdn_role_type">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="Called"/>
 *     &lt;enumeration value="Caller"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "isdn_role_type")
@XmlEnum
public enum IsdnRoleType {

    @XmlEnumValue("Called")
    CALLED("Called"),
    @XmlEnumValue("Caller")
    CALLER("Caller");
    private final String value;

    IsdnRoleType(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static IsdnRoleType fromValue(String v) {
        for (IsdnRoleType c: IsdnRoleType.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
