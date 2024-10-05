import QtQuick 2.3
import QtGraphicalEffects 1.0


Item {
    id: root
    ////////// IC7 LCD RESOLUTION ////////////////////////////////////////////
    width: 800
    height: 480
    
    z: 0
    
    property int myyposition: 0
    property int udp_message: rpmtest.udp_packetdata

    property bool udp_up: udp_message & 0x01
    property bool udp_down: udp_message & 0x02
    property bool udp_left: udp_message & 0x04
    property bool udp_right: udp_message & 0x08

    property int membank2_byte7: rpmtest.can203data[10]
    property int inputs: rpmtest.inputsdata

    //Inputs//31 max!!
    property bool ignition: inputs & 0x01
    property bool battery: inputs & 0x02
    property bool lapmarker: inputs & 0x04
    property bool rearfog: inputs & 0x08
    property bool mainbeam: inputs & 0x10
    property bool up_joystick: inputs & 0x20 || root.udp_up
    property bool leftindicator: inputs & 0x40
    property bool rightindicator: inputs & 0x80
    property bool brake: inputs & 0x100
    property bool oil: inputs & 0x200
    property bool seatbelt: inputs & 0x400
    property bool sidelight: inputs & 0x800
    property bool tripresetswitch: inputs & 0x1000
    property bool down_joystick: inputs & 0x2000 || root.udp_down
    property bool doorswitch: inputs & 0x4000
    property bool airbag: inputs & 0x8000
    property bool tc: inputs & 0x10000
    property bool abs: inputs & 0x20000
    property bool mil: inputs & 0x40000
    property bool shift1_id: inputs & 0x80000
    property bool shift2_id: inputs & 0x100000
    property bool shift3_id: inputs & 0x200000
    property bool service_id: inputs & 0x400000
    property bool race_id: inputs & 0x800000
    property bool sport_id: inputs & 0x1000000
    property bool cruise_id: inputs & 0x2000000
    property bool reverse: inputs & 0x4000000
    property bool handbrake: inputs & 0x8000000
    property bool tc_off: inputs & 0x10000000
    property bool left_joystick: inputs & 0x20000000 || root.udp_left
    property bool right_joystick: inputs & 0x40000000 || root.udp_right

    property int odometer: rpmtest.odometer0data/10*0.62 //Need to div by 10 to get 6 digits with leading 0
    property int tripmeter: rpmtest.tripmileage0data*0.62
    property real value: 0
    property real shiftvalue: 0

    property real rpm: rpmtest.rpmdata
    property real rpmlimit: 8000 //Originally was 7k, switched to 8000 -t
    property real rpmdamping: 5
    property real speed: rpmtest.speeddata
    property int speedunits: 2

    property real watertemp: rpmtest.watertempdata
    property real waterhigh: 0
    property real waterlow: 80
    property real waterunits: 1

    property real fuel: rpmtest.fueldata
    property real fuelhigh: 0
    property real fuellow: 0
    property real fuelunits
    property real fueldamping

    property real o2: rpmtest.o2data
    property real map: rpmtest.mapdata
    property real maf: rpmtest.mafdata

    property real oilpressure: rpmtest.oilpressuredata
    property real oilpressurehigh: 0
    property real oilpressurelow: 0
    property real oilpressureunits: 0

    property real oiltemp: rpmtest.oiltempdata
    property real oiltemphigh: 90
    property real oiltemplow: 90
    property real oiltempunits: 1

    property real batteryvoltage: rpmtest.batteryvoltagedata

    property int mph: (speed * 0.62)

    property int gearpos: rpmtest.geardata

    property real speed_spring: 1
    property real speed_damping: 1

    property real rpm_needle_spring: 3.0 //if(rpm<1000)0.6 ;else 3.0
    property real rpm_needle_damping: 0.2 //if(rpm<1000).15; else 0.2

    property bool changing_page: rpmtest.changing_pagedata

    property string white_color: "#FFFFFF"
    property string primary_color: "#000000"; //#FFBF00 for amber
    property string night_light_color: "#ACFAFF"  //Pale Indiglo Blue
    property string sweetspot_color: "#FFA500" //Cam Changeover Rev colpr
    property string warning_red: "#C60000" //Redline/Warning colors
    property string nightlight_pink: "#F85653"
    property string nightlight_orange: "#F89553"
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
    property string soft_bkg_color: "#222222"

    property int mileage_fake: 31582
    x: 0
    y: 0

    function padStart(str, targetLength, padString) {
        while (str.length < targetLength) {
            str = padString + str;
        }
        return str;
    }
    function odoString(){
        if(root.speedunits === 0){
                return padStart((root.odometer/.62).toFixed(0).toString(), 6, "0")
            }
        else{
            return padStart(root.odometer.toFixed(0).toString(), 6, "0")
        }

    }

    Item {
        id: background_rect
        x: 0   
        y: 0
        width: 800
        height: 480
        z: 0
        Image{
            source: if(root.sidelight) "./heritage/dark_wood_bkg"; else "./heritage/wood_bkg.png"
            x:0;y:0
        }
    }
    Item{
        id: tachometer
        height: 401; width: 401;
        x:0;y:39.4
        Image{ 
            source: "./heritage/tachometer_bkg.png"
            z:1
        }
        Image{
            source: "./heritage/center_pivot.png"
            x:170;y:170;z:4
        }
        Image{
            id: tach_needle
            source: "./heritage/needle.png"
            x:191;y:49;z:3
            transform:[
                Rotation {
                    id: tachneedle_rotate
                    origin.y: 151
                    origin.x: 8.5
                    angle:Math.min(Math.max(-129, Math.round((root.rpm/1000)*25.7) - 129), 129)
                    Behavior on angle{
                        SpringAnimation {
                            spring: 1.2
                            damping:.16
                        }
                    }
                }
            ]
        }
        
    }
    Item{
        id: speedometer
        height: 401; width: 401;
        x:400;y:39.4
        z:1
        Image{ 
            source: if(root.speedunits === 0) "./heritage/speedometer_kmh_bkg.png"; else "./heritage/speedometer_bkg.png"
            z:1;
        }    
    }
    Image{
            source: "./heritage/center_pivot.png"
            x:570;y:209.4;z:6
        }
    Image{
        id: mph_needle
        source: "./heritage/needle.png"
        x:591;y:88.4;z:6
        transform:[
            Rotation {
                id: mph_rotate
                origin.y: 151
                origin.x: 8.5
                angle:if(root.speedunits === 0) Math.min(Math.max(-133.5, Math.round((root.speed/10)*12.2) - 133.5), 131.5);else Math.min(Math.max(-127, Math.round((root.mph/10)*18.3) - 127), 127)
                Behavior on angle{
                    SpringAnimation {
                        spring: 1.2
                        damping:.16
                    }
                }
            }
        ]
    }
    Item{
        id:odometer
        z:2
        Image{
            source: "./heritage/odometer_holster.png"
            x: 543; y: 275; z: 3
        }
        Image{
            x: 548; y: 280; z: 3
            source: "./heritage/odometer_numbers/"+odoString()[0]+".png"
        }
        Image{
            x: 565; y: 280; z: 3
            source: "./heritage/odometer_numbers/"+odoString()[1]+".png"
        }
        Image{
            x: 582; y: 280; z: 3
            source: "./heritage/odometer_numbers/"+odoString()[2]+".png"
        }
        Image{
            x: 599; y: 280; z: 3
            source: "./heritage/odometer_numbers/"+odoString()[3]+".png"
        }
        Image{
            x: 616; y: 280; z: 3
            source: "./heritage/odometer_numbers/"+odoString()[4]+".png"
        }
        Image{
            x: 633; y: 280; z: 3
            source: "./heritage/odometer_numbers/"+odoString()[5]+".png"
        }
    }
    Item{
        id: oilpressure
        Image{
            source: "./heritage/big_oil_pressure.png"
            x: 373; y:20; z:3
        }
        Image{
            visible: root.oil | root.oilpressure < root.oilpressurelow
            source: "./heritage/big_oil_pressure_lit.png"
            x: 366; y:12; z:3
        }
    }   
    Item{
        id: water_temp
        Image{
            source: "./heritage/water_celcius_marks.png"
            x: 10;y: 465; z:3
            opacity: .4
        }
        Image{ 
            source: "./heritage/small_needle.png"
            x: if (root.watertemp <=60) 15; else if(root.watertemp > 60 && root.watertemp < 120) 15 + (root.watertemp - 60)*2.67; else 178
            y: 457; z: 4;
        }
    }
    Item{
        id: fuel_gauge
        Image{
            source: "./heritage/fuel_marks.png"
            x: 610; y: 460; z:3
            opacity: .4
        }
        Image{ 
             source: "./heritage/small_needle.png"
                x: if (root.fuel === 0) 613; else 613 + (root.fuel*1.7)
                y: 457; z: 4;
            }
    }
    Item{
        id: idiot_lights
        z: 5
        Item{
            id: parking_brake_light
            Image{
                x: 411; y: 365
                z: 2
                source: "./heritage/small_red_dim.png"
            }
            Image{
                x: 399; y: 353
                z: 3
                source: "./heritage/small_red_lit.png"
                visible: root.brake
            }
        }
        Item{
            id: cel_light
            Image{
                x: 361; y: 365
                z: 2
                source: "./heritage/small_yellow_dim.png"
            }
            Image{
                x: 349; y: 353
                z: 3
                source: "./heritage/small_yellow_lit.png"
                visible: root.mil
            }
        }
        Item{
            id: airbag_light
            Image{
                x: 361; y: 425
                z: 2
                source: "./heritage/small_yellow_dim.png"
            }
            Image{
                x: 349; y: 413
                z: 3
                source: "./heritage/small_yellow_lit.png"
                visible: root.airbag
            }
        }
        Item{
            id: fuel_light
            Image{
                x: 411; y: 425
                z: 2
                source: "./heritage/small_yellow_dim.png"
            }
            Image{
                id: fuel_light_blink
                x: 399; y: 413
                z: 3
                source: "./heritage/small_yellow_lit.png"
                visible: root.fuel <= root.fuellow
                Timer{
                    id: fuel_low_timer
                    running:true 
                    interval: 800
                    repeat: true
                    onTriggered: animatefuellow.start()
                }
                SequentialAnimation{
                    id: animatefuellow
                        NumberAnimation{
                            target: fuel_light_blink
                            property: "opacity"
                            from: 0; to: 1
                            duration: 500
                        }
                }
            }
        }
        Item{
            id: highbeam_light
            Image{ 
                source: "./heritage/big_blue_dim.png"
                x: 110; y: 333; z:2
            }
            Image{
                source: "./heritage/big_blue_lit.png"
                x: 102; y: 324; z:3
                visible: root.mainbeam
            }
        }
        Item{ 
            id: battery_light
            Image{
                source: "./heritage/big_red_dim.png"
                x: 246; y: 333; z:2
            }
            Image{
                source: "./heritage/big_red_lit.png"
                x: 237; y: 324; z:3
                visible: root.battery
            }
        }
        Item{ 
            id: indicator_light
            Image{
                source: "./heritage/big_green_dim.png"
                x: 515; y: 333; z:4
            }
            Image{
                source: "./heritage/big_green_lit.png"
                x: 505; y: 323; z:5
                visible: root.leftindicator || root.rightindicator
            }
        }
        Item{
            id:seatbelt_light
            Image{
                source: "./heritage/big_red_dim.png"
                x:650; y: 333; z: 4
            }
            Image{
                source: "./heritage/big_red_lit.png"
                x: 642; y: 323; z:5
                visible: root.seatbelt
            }
        }
    }
}//End Lotus Elan S1 Dash

