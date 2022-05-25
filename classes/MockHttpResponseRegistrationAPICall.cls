@isTest
global class MockHttpResponseRegistrationAPICall implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       
        String json= '{'+
'    "links": ['+
'        {'+
'            "rel": "first",'+
'            "href": "https://api.bizzabo.com/api/registrations?page=0&size=50"'+
'        },'+
'        {'+
'            "rel": "self",'+
'            "href": "https://api.bizzabo.com/api/registrations?page=0&size=50"'+
'        },'+
'        {'+
'            "rel": "next",'+
'            "href": "https://api.bizzabo.com/api/registrations?page=1&size=50"'+
'        },'+
'        {'+
'            "rel": "last",'+
'            "href": "https://api.bizzabo.com/api/registrations?page=1&size=50"'+
'        }'+
'    ],'+
'    "content": ['+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser21537293601@eab.com",'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler"'+
'            },'+
'            "properties": {'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler",'+
'                "company": "George Mason",'+
'                "email": "testuser21537293601@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242954/settings/registration/9I3ZCBv8Nk714z7rAHTAePXAsxxF2ZnTgsj2CEzlllD51VDN0-5S02oUfPHz7frc",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=9I3ZCBv8Nk714z7rAHTAePXAsxxF2ZnTgsj2CEzlllALClTw294WFsmdIUvEzg6C&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242954/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "RSVP",'+
'            "price": 0,'+
'            "orderType": "online",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "valid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149807,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-10T14:28:53.571+0000",'+
'            "paymentDate": "2020-09-10T14:28:53.571+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 661842,'+
'            "eventId": 242954,'+
'            "orderId": 3830432,'+
'            "created": "2020-09-10T14:28:40.000+0000",'+
'            "modified": "2020-09-10T14:28:53.712+0000",'+
'            "id": 6861498'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser21537293601@eab.com",'+
'                "firstName": "Rachel",'+
'                "lastName": "Becker"'+
'            },'+
'            "properties": {'+
'                "summary": "Test",'+
'                "firstName": "Rachel",'+
'                "lastName": "Becker",'+
'                "prefix": "Ms.",'+
'                "company": "Test School",'+
'                "email": "testuser21537293601@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242954/settings/registration/y9DCtTrNo0oLZ7bFqAvnIBNmvJqnswW6-ch_OF6xx3eHXXjjR0Oh1YBbqwu5Ur6o",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=y9DCtTrNo0oLZ7bFqAvnIBNmvJqnswW6-ch_OF6xx3eHXXjjR0Oh1YBbqwu5Ur6o&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242954/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "RSVP",'+
'            "price": 0,'+
'            "orderType": "online",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149807,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-10T14:24:21.000+0000",'+
'            "paymentDate": "2020-09-10T14:24:21.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 6670849,'+
'            "eventId": 242954,'+
'            "orderId": 3829985,'+
'            "created": "2020-09-10T14:23:44.000+0000",'+
'            "modified": "2020-09-10T14:26:36.935+0000",'+
'            "id": 6860895'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Leo",'+
'                "lastName": "McGarry"'+
'            },'+
'            "properties": {'+
'                "firstName": "Leo",'+
'                "country": "United States",'+
'                "lastName": "McGarry",'+
'                "company": "EAB",'+
'                "title": "Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/O2QkIhkWwGWQ2w-5ddOqM6P-kALbIBp32InlWFbs4YjLOnFDAochATNfpjSbAruB",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=O2QkIhkWwGWQ2w-5ddOqM6P-kALbIBp32InlWFbs4YjLOnFDAochATNfpjSbAruB&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "On Invite List",'+
'            "price": 0,'+
'            "orderType": "online",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "promoCode": "Invite",'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149857,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-09T19:29:46.000+0000",'+
'            "paymentDate": "2020-09-09T19:29:46.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 70066,'+
'            "eventId": 242966,'+
'            "orderId": 3745136,'+
'            "created": "2020-09-09T19:29:30.000+0000",'+
'            "modified": "2020-09-10T13:03:28.090+0000",'+
'            "id": 6747071'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn"'+
'            },'+
'            "properties": {'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn",'+
'                "company": "Kempsville High School",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/wG2CyKHBITs2LCHH9wQNBHzuQzWeUA_1g_GeuCLMV1WSyZ2LyUKUtnAposCz288D",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=wG2CyKHBITs2LCHH9wQNBHzuQzWeUA_1g_GeuCLMV1WSyZ2LyUKUtnAposCz288D&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Approved Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149834,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-09T18:42:05.000+0000",'+
'            "paymentDate": "2020-09-09T18:42:05.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 6787656,'+
'            "eventId": 242966,'+
'            "orderId": 3740232,'+
'            "created": "2020-09-09T18:42:05.000+0000",'+
'            "modified": "2020-09-09T18:43:45.259+0000",'+
'            "id": 6738691'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Joshua",'+
'                "lastName": "Lyman"'+
'            },'+
'            "properties": {'+
'                "firstName": "Joshua",'+
'                "lastName": "Lyman",'+
'                "company": "Yale University",'+
'                "title": "Deputy Chief of Staff",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/OYkurPQs5SslGyrP1f4f3CqbcjYxFwJu1gkfWI03JKf51VDN0-5S02oUfPHz7frc",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=OYkurPQs5SslGyrP1f4f3CqbcjYxFwJu1gkfWI03JKf51VDN0-5S02oUfPHz7frc&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-24T19:41:43.000+0000",'+
'            "paymentDate": "2020-09-24T19:41:43.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7290306,'+
'            "eventId": 242966,'+
'            "orderId": 4235704,'+
'            "created": "2020-09-24T19:41:42.000+0000",'+
'            "modified": "2020-09-25T22:02:07.301+0000",'+
'            "id": 7404100'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Jason",'+
'                "lastName": "Street"'+
'            },'+
'            "properties": {'+
'                "firstName": "Jason",'+
'                "lastName": "Street",'+
'                "company": "William & Mary",'+
'                "title": "Dean of Admissions",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/Eu0fMpmCh2TXqNMQ51RXMPXAsxxF2ZnTgsj2CEzlllD51VDN0-5S02oUfPHz7frc",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=Eu0fMpmCh2TXqNMQ51RXMPXAsxxF2ZnTgsj2CEzlllD51VDN0-5S02oUfPHz7frc&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Request attendance",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-14T17:39:23.000+0000",'+
'            "paymentDate": "2020-09-14T17:39:23.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 661837,'+
'            "eventId": 242966,'+
'            "orderId": 4039304,'+
'            "created": "2020-09-14T17:39:22.000+0000",'+
'            "modified": "2020-09-17T14:31:53.445+0000",'+
'            "id": 7107898'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Jason",'+
'                "lastName": "Street"'+
'            },'+
'            "properties": {'+
'                "firstName": "Jason",'+
'                "lastName": "Street",'+
'                "company": "William & Mary",'+
'                "title": "Dean of Admissions",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/Eu0fMpmCh2TXqNMQ51RXMPXAsxxF2ZnTgsj2CEzlllD51VDN0-5S02oUfPHz7frc",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=Eu0fMpmCh2TXqNMQ51RXMPXAsxxF2ZnTgsj2CEzlllD51VDN0-5S02oUfPHz7frc&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "On Invite List",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149857,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-14T17:38:59.000+0000",'+
'            "paymentDate": "2020-09-14T17:38:59.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 661837,'+
'            "eventId": 242966,'+
'            "orderId": 4039291,'+
'            "created": "2020-09-14T17:38:59.000+0000",'+
'            "modified": "2020-09-17T14:32:25.439+0000",'+
'            "id": 7107880'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Leo",'+
'                "lastName": "Bartlet"'+
'            },'+
'            "properties": {'+
'                "firstName": "Leo",'+
'                "country": "Albania",'+
'                "lastName": "Bartlet",'+
'                "industry": "Accounting",'+
'                "company": "TestOrg",'+
'                "title": "Test",'+
'                "sessionRegistration": [],'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/O2QkIhkWwGWQ2w-5ddOqM6P-kALbIBp32InlWFbs4YjLOnFDAochATNfpjSbAruB",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=O2QkIhkWwGWQ2w-5ddOqM6P-kALbIBp32InlWFbs4YjLOnFDAochATNfpjSbAruB&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Request attendance",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-10T13:04:54.000+0000",'+
'            "paymentDate": "2020-09-10T13:04:54.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 70066,'+
'            "eventId": 242966,'+
'            "orderId": 3822681,'+
'            "created": "2020-09-10T13:04:54.000+0000",'+
'            "modified": "2020-09-17T14:32:39.339+0000",'+
'            "id": 6851652'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Rachel",'+
'                "lastName": "Becker"'+
'            },'+
'            "properties": {'+
'                "firstName": "Rachel",'+
'                "country": "United States",'+
'                "lastName": "Becker",'+
'                "company": "EAB",'+
'                "title": "Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/RXkQ4CbQBkncuck3uh5ByhNmvJqnswW6-ch_OF6xx3eHXXjjR0Oh1YBbqwu5Ur6o",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=RXkQ4CbQBkncuck3uh5ByhNmvJqnswW6-ch_OF6xx3eHXXjjR0Oh1YBbqwu5Ur6o&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Request attendance",'+
'            "price": 0,'+
'            "orderType": "online",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-09T18:52:23.000+0000",'+
'            "paymentDate": "2020-09-09T18:52:23.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 6670849,'+
'            "eventId": 242966,'+
'            "orderId": 3741097,'+
'            "created": "2020-09-09T18:52:13.000+0000",'+
'            "modified": "2020-09-17T14:30:57.480+0000",'+
'            "id": 6740294'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Allie",'+
'                "lastName": "Turner"'+
'            },'+
'            "properties": {'+
'                "firstName": "Allie",'+
'                "lastName": "Turner",'+
'                "sessionRegistration": [],'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/ZMBi5Gz4TA5cnHZ8QpezPBNmvJqnswW6-ch_OF6xx3eHXXjjR0Oh1YBbqwu5Ur6o",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=ZMBi5Gz4TA5cnHZ8QpezPBNmvJqnswW6-ch_OF6xx3eHXXjjR0Oh1YBbqwu5Ur6o&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-16T21:36:01.000+0000",'+
'            "paymentDate": "2020-09-16T21:36:01.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7169996,'+
'            "eventId": 242966,'+
'            "orderId": 4094676,'+
'            "created": "2020-09-16T21:36:01.000+0000",'+
'            "modified": "2020-09-17T14:31:14.753+0000",'+
'            "id": 7194430'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn"'+
'            },'+
'            "properties": {'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn",'+
'                "company": "Kempsville High School",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/wG2CyKHBITs2LCHH9wQNBHzuQzWeUA_1g_GeuCLMV1WSyZ2LyUKUtnAposCz288D",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=wG2CyKHBITs2LCHH9wQNBHzuQzWeUA_1g_GeuCLMV1WSyZ2LyUKUtnAposCz288D&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "On Invite List",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149857,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-10T13:00:11.000+0000",'+
'            "paymentDate": "2020-09-10T13:00:11.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 6787656,'+
'            "eventId": 242966,'+
'            "orderId": 3822306,'+
'            "created": "2020-09-10T13:00:11.000+0000",'+
'            "modified": "2020-09-17T14:32:53.851+0000",'+
'            "id": 6851130'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins"'+
'            },'+
'            "properties": {'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins",'+
'                "company": "Intelligence and Homeland Security - GDIT Moderator",'+
'                "title": "CEO and Founder of The Muse",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/0JlABmlO9JLA5AbofwMvX_XAsxxF2ZnTgsj2CEzlllD51VDN0-5S02oUfPHz7frc",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=0JlABmlO9JLA5AbofwMvX_XAsxxF2ZnTgsj2CEzlllD51VDN0-5S02oUfPHz7frc&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Request attendance",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-10T12:59:53.000+0000",'+
'            "paymentDate": "2020-09-10T12:59:53.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 652476,'+
'            "eventId": 242966,'+
'            "orderId": 3822278,'+
'            "created": "2020-09-10T12:59:53.000+0000",'+
'            "modified": "2020-09-17T14:33:35.999+0000",'+
'            "id": 6851104'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Josh",'+
'                "lastName": "Lyman"'+
'            },'+
'            "properties": {'+
'                "firstName": "Josh",'+
'                "country": "United States",'+
'                "lastName": "Lyman",'+
'                "company": "EAB",'+
'                "title": "Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/0ni5TlcW8FlJz_ILY4cDD49zoZIEqKEA5R9zbF3nQ8ySyZ2LyUKUtnAposCz288D",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=0ni5TlcW8FlJz_ILY4cDD49zoZIEqKEA5R9zbF3nQ8ySyZ2LyUKUtnAposCz288D&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Request attendance",'+
'            "price": 0,'+
'            "orderType": "online",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-09T19:25:07.000+0000",'+
'            "paymentDate": "2020-09-09T19:25:07.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 6787623,'+
'            "eventId": 242966,'+
'            "orderId": 3744575,'+
'            "created": "2020-09-09T19:24:51.000+0000",'+
'            "modified": "2020-09-17T14:33:49.867+0000",'+
'            "id": 6746188'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Rachel",'+
'                "lastName": "Becker"'+
'            },'+
'            "properties": {'+
'                "firstName": "Rachel",'+
'                "country": "United States",'+
'                "lastName": "Becker",'+
'                "company": "EAB",'+
'                "title": "Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/0ni5TlcW8FlJz_ILY4cDD1JlHfySOTnLlWE9y5DJLoGDoQdHoqbcwy5xXuD_D-cf",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=0ni5TlcW8FlJz_ILY4cDD1JlHfySOTnLlWE9y5DJLoGDoQdHoqbcwy5xXuD_D-cf&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Request attendance",'+
'            "price": 0,'+
'            "orderType": "online",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-09T19:23:26.000+0000",'+
'            "paymentDate": "2020-09-09T19:23:26.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 6787587,'+
'            "eventId": 242966,'+
'            "orderId": 3744418,'+
'            "created": "2020-09-09T19:23:13.000+0000",'+
'            "modified": "2020-09-17T14:34:21.768+0000",'+
'            "id": 6745862'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn"'+
'            },'+
'            "properties": {'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn",'+
'                "company": "Princeton University",'+
'                "title": "Deputy Communications Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk8OmImQcp6GYa8JJylm99HRs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk8OmImQcp6GYa8JJylm99HRs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T21:55:34.000+0000",'+
'            "paymentDate": "2020-09-25T21:55:34.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7304415,'+
'            "eventId": 242966,'+
'            "orderId": 4255658,'+
'            "created": "2020-09-25T21:55:34.000+0000",'+
'            "modified": "2020-09-29T11:11:05.119+0000",'+
'            "id": 7433377'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "CJ",'+
'                "lastName": "Cregg"'+
'            },'+
'            "properties": {'+
'                "firstName": "CJ",'+
'                "lastName": "Cregg",'+
'                "test9": "Closing equity gaps on campus",'+
'                "company": "University of California Berkeley",'+
'                "title": "Press Secretary",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk0c0u_p6SjJGn-ko_E88fJ5s93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk0c0u_p6SjJGn-ko_E88fJ5s93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:59:52.000+0000",'+
'            "paymentDate": "2020-09-29T14:59:52.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7297952,'+
'            "eventId": 242966,'+
'            "orderId": 4300827,'+
'            "created": "2020-09-29T14:59:52.000+0000",'+
'            "modified": "2020-09-29T20:12:21.937+0000",'+
'            "id": 7497224'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum"'+
'            },'+
'            "properties": {'+
'                "test_4": ['+
'                    "[[[Using Navigate in a virtual/hybrid environment]]]"'+
'                ],'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum",'+
'                "test3": ['+
'                    "[Engaging faculty and staff in using the Navigate platform]"'+
'                ],'+
'                "attendeetype": "Guest / Non-Navigate Partner",'+
'                "company": "University of Virginia",'+
'                "title": "Vice President",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:39:21.000+0000",'+
'            "paymentDate": "2020-09-29T14:39:21.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7199619,'+
'            "eventId": 242966,'+
'            "orderId": 4300165,'+
'            "created": "2020-09-29T14:39:21.000+0000",'+
'            "modified": "2020-09-29T20:12:47.802+0000",'+
'            "id": 7496268'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436033@eab.com",'+
'                "firstName": "Anneke",'+
'                "lastName": "Herman"'+
'            },'+
'            "properties": {'+
'                "firstName": "Anneke",'+
'                "lastName": "Herman",'+
'                "test3": ['+
'                    "[Closing equity gaps on campus]"'+
'                ],'+
'                "attendeetype": "Guest",'+
'                "company": "EAB",'+
'                "title": "Managing Director, Business Solutions",'+
'                "email": "testuser2175436033@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/rTxfvm14zdtEeJ2m4CI0M5dhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=rTxfvm14zdtEeJ2m4CI0M5dhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:41:53.000+0000",'+
'            "paymentDate": "2020-09-29T14:41:53.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7199015,'+
'            "eventId": 242966,'+
'            "orderId": 4300251,'+
'            "created": "2020-09-29T14:41:52.000+0000",'+
'            "modified": "2020-09-29T20:12:40.598+0000",'+
'            "id": 7496384'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436034@eab.com",'+
'                "firstName": "CJ",'+
'                "lastName": "Cregg"'+
'            },'+
'            "properties": {'+
'                "firstName": "CJ",'+
'                "lastName": "Cregg",'+
'                "test9": "Closing equity gaps on campus",'+
'                "company": "University of California Berkeley",'+
'                "title": "Press Secretary",'+
'                "email": "testuser2175436034@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk0c0u_p6SjJGn-ko_E88fJ5s93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk0c0u_p6SjJGn-ko_E88fJ5s93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:58:42.000+0000",'+
'            "paymentDate": "2020-09-29T14:58:42.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7297952,'+
'            "eventId": 242966,'+
'            "orderId": 4300780,'+
'            "created": "2020-09-29T14:58:41.000+0000",'+
'            "modified": "2020-09-29T20:13:00.084+0000",'+
'            "id": 7497167'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Zoey",'+
'                "lastName": "Bartlet"'+
'            },'+
'            "properties": {'+
'                "firstName": "Zoey",'+
'                "lastName": "Bartlet",'+
'                "test3": ['+
'                    "[Closing equity gaps on campus, Engaging faculty and staff in using the Navigate platform]"'+
'                ],'+
'                "company": "Test",'+
'                "title": "Test",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/eiuZE8gb0FX11-9XTWjutEc0u_p6SjJGn-ko_E88fJ5s93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=eiuZE8gb0FX11-9XTWjutEc0u_p6SjJGn-ko_E88fJ5s93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:34:38.000+0000",'+
'            "paymentDate": "2020-09-29T14:34:38.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7308631,'+
'            "eventId": 242966,'+
'            "orderId": 4299946,'+
'            "created": "2020-09-29T14:34:38.000+0000",'+
'            "modified": "2020-09-29T20:15:22.532+0000",'+
'            "id": 7495957'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins"'+
'            },'+
'            "properties": {'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins",'+
'                "test3": ['+
'                    "[[Using Navigate in a virtual/hybrid environment]]"'+
'                ],'+
'                "attendeetype": "Navigate Partner",'+
'                "company": "Dillon Community College",'+
'                "title": "Chief Business Officer",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/RKth8Sd-_dI2ckFrhJOBsZdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=RKth8Sd-_dI2ckFrhJOBsZdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:38:02.000+0000",'+
'            "paymentDate": "2020-09-29T14:38:02.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7202566,'+
'            "eventId": 242966,'+
'            "orderId": 4300122,'+
'            "created": "2020-09-29T14:38:02.000+0000",'+
'            "modified": "2020-09-29T20:15:02.673+0000",'+
'            "id": 7496201'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "test1user2175436032@eab.com",'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum"'+
'            },'+
'            "properties": {'+
'                "test_4": ['+
'                    "[[Using Navigate in a virtual/hybrid environment]]"'+
'                ],'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum",'+
'                "test3": ['+
'                    "[[Tips and tricks for successfully implementing the Navigate platform as a new partner]]"'+
'                ],'+
'                "attendeetype": "Guest / Non-Navigate Partner",'+
'                "company": "University of Virginia",'+
'                "title": "Vice President",'+
'                "email": "test1user2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T22:23:57.000+0000",'+
'            "paymentDate": "2020-09-25T22:23:57.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7199619,'+
'            "eventId": 242966,'+
'            "orderId": 4255849,'+
'            "created": "2020-09-25T22:23:57.000+0000",'+
'            "modified": "2020-09-29T20:16:20.825+0000",'+
'            "id": 7433671'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Zoey",'+
'                "lastName": "Bartlet"'+
'            },'+
'            "properties": {'+
'                "firstName": "Karlos",'+
'                "lastName": "Taco",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/qUs1yrKqhsUIzUhbN2XoV_sHGr6ZVjreA0_-EKuohNroRyWI4GJyzl2kvcntyZaO",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=qUs1yrKqhsUIzUhbN2XoV_sHGr6ZVjreA0_-EKuohNroRyWI4GJyzl2kvcntyZaO&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T22:25:20.000+0000",'+
'            "paymentDate": "2020-09-25T22:25:20.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7326728,'+
'            "eventId": 242966,'+
'            "orderId": 4255861,'+
'            "created": "2020-09-25T22:25:20.000+0000",'+
'            "modified": "2020-09-29T20:16:12.952+0000",'+
'            "id": 7433695'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler"'+
'            },'+
'            "properties": {'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler",'+
'                "attendeetype": "Navigate Partner",'+
'                "test9": "Closing equity gaps on campus",'+
'                "company": "City College of New York",'+
'                "title": "Communications Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/0JlABmlO9JLA5AbofwMvX5G9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=0JlABmlO9JLA5AbofwMvX5G9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T15:18:08.000+0000",'+
'            "paymentDate": "2020-09-29T15:18:08.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7186336,'+
'            "eventId": 242966,'+
'            "orderId": 4301476,'+
'            "created": "2020-09-29T15:18:08.000+0000",'+
'            "modified": "2020-09-29T20:11:56.676+0000",'+
'            "id": 7498172'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Donna",'+
'                "lastName": "Moss"'+
'            },'+
'            "properties": {'+
'                "firstName": "Donna",'+
'                "lastName": "Moss",'+
'                "attendeetype": "Guest",'+
'                "test9": "Closing equity gaps on campus",'+
'                "company": "University of Wisconsin",'+
'                "title": "Assistant",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/BT5KBcQGKEKCHz5nE-MWlZG9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=BT5KBcQGKEKCHz5nE-MWlZG9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T15:14:19.000+0000",'+
'            "paymentDate": "2020-09-29T15:14:19.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7190920,'+
'            "eventId": 242966,'+
'            "orderId": 4301357,'+
'            "created": "2020-09-29T15:14:11.000+0000",'+
'            "modified": "2020-09-29T20:12:04.137+0000",'+
'            "id": 7498019'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Ainsley",'+
'                "lastName": "Hayes"'+
'            },'+
'            "properties": {'+
'                "firstName": "Ainsley",'+
'                "lastName": "Hayes",'+
'                "attendeetype": "Guest",'+
'                "test9": "Engaging faculty and staff in using the Navigate platform",'+
'                "company": "Smith College",'+
'                "title": "Associate Counsel",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/_g_KAjM1H1ap113lvGSgrPfjnyzg8Y-7kqLQsNins4BhamE3epKTq6praOFUSNrN",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=_g_KAjM1H1ap113lvGSgrPfjnyzg8Y-7kqLQsNins4BhamE3epKTq6praOFUSNrN&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T15:49:52.000+0000",'+
'            "paymentDate": "2020-09-29T15:49:52.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7290201,'+
'            "eventId": 242966,'+
'            "orderId": 4302590,'+
'            "created": "2020-09-29T15:49:51.000+0000",'+
'            "modified": "2020-09-29T20:11:49.167+0000",'+
'            "id": 7499720'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Joshua",'+
'                "lastName": "Lyman"'+
'            },'+
'            "properties": {'+
'                "firstName": "Joshua",'+
'                "lastName": "Lyman",'+
'                "attendeetype": "Navigate Partner",'+
'                "test9": "Closing equity gaps on campus",'+
'                "company": "Yale University",'+
'                "title": "Deputy Chief of Staff",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/OYkurPQs5SslGyrP1f4f3CqbcjYxFwJu1gkfWI03JKf51VDN0-5S02oUfPHz7frc",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=OYkurPQs5SslGyrP1f4f3CqbcjYxFwJu1gkfWI03JKf51VDN0-5S02oUfPHz7frc&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T15:04:12.000+0000",'+
'            "paymentDate": "2020-09-29T15:04:12.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7290306,'+
'            "eventId": 242966,'+
'            "orderId": 4300951,'+
'            "created": "2020-09-29T15:04:11.000+0000",'+
'            "modified": "2020-09-29T20:12:14.191+0000",'+
'            "id": 7497421'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum"'+
'            },'+
'            "properties": {'+
'                "test_4": ['+
'                    "[Using Navigate in a virtual/hybrid environment]"'+
'                ],'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum",'+
'                "test3": ['+
'                    "[Tips and tricks for successfully implementing the Navigate platform as a new partner]"'+
'                ],'+
'                "attendeetype": "Guest / Non-Navigate Partner",'+
'                "company": "University of Virginia",'+
'                "title": "Vice President",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T22:21:06.000+0000",'+
'            "paymentDate": "2020-09-25T22:21:06.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7199619,'+
'            "eventId": 242966,'+
'            "orderId": 4255832,'+
'            "created": "2020-09-25T22:21:06.000+0000",'+
'            "modified": "2020-09-29T20:17:39.379+0000",'+
'            "id": 7433639'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum"'+
'            },'+
'            "properties": {'+
'                "test_4": ['+
'                    "[Using Navigate in a virtual/hybrid environment]"'+
'                ],'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum",'+
'                "test3": ['+
'                    "[Tips and tricks for successfully implementing the Navigate platform as a new partner]"'+
'                ],'+
'                "attendeetype": "Guest / Non-Navigate Partner",'+
'                "company": "University of Virginia",'+
'                "title": "Vice President",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T22:21:35.000+0000",'+
'            "paymentDate": "2020-09-25T22:21:35.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7199619,'+
'            "eventId": 242966,'+
'            "orderId": 4255836,'+
'            "created": "2020-09-25T22:21:35.000+0000",'+
'            "modified": "2020-09-29T20:17:31.196+0000",'+
'            "id": 7433644'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler"'+
'            },'+
'            "properties": {'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler",'+
'                "company": "City College of New York",'+
'                "title": "Communications Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/0JlABmlO9JLA5AbofwMvX5G9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=0JlABmlO9JLA5AbofwMvX5G9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T22:16:58.000+0000",'+
'            "paymentDate": "2020-09-25T22:16:58.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7186336,'+
'            "eventId": 242966,'+
'            "orderId": 4255801,'+
'            "created": "2020-09-25T22:16:57.000+0000",'+
'            "modified": "2020-09-29T20:17:50.811+0000",'+
'            "id": 7433600'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler"'+
'            },'+
'            "properties": {'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler",'+
'                "company": "City College of New York",'+
'                "title": "Communications Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/0JlABmlO9JLA5AbofwMvX5G9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=0JlABmlO9JLA5AbofwMvX5G9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T22:14:31.000+0000",'+
'            "paymentDate": "2020-09-25T22:14:31.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7186336,'+
'            "eventId": 242966,'+
'            "orderId": 4255781,'+
'            "created": "2020-09-25T22:14:31.000+0000",'+
'            "modified": "2020-09-29T20:18:02.987+0000",'+
'            "id": 7433570'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler"'+
'            },'+
'            "properties": {'+
'                "firstName": "Toby",'+
'                "lastName": "Ziegler",'+
'                "company": "City College of New York",'+
'                "title": "Communications Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/0JlABmlO9JLA5AbofwMvX5G9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=0JlABmlO9JLA5AbofwMvX5G9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T22:16:13.000+0000",'+
'            "paymentDate": "2020-09-25T22:16:13.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7186336,'+
'            "eventId": 242966,'+
'            "orderId": 4255795,'+
'            "created": "2020-09-25T22:16:13.000+0000",'+
'            "modified": "2020-09-29T20:17:56.698+0000",'+
'            "id": 7433592'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Joshua",'+
'                "lastName": "Lyman"'+
'            },'+
'            "properties": {'+
'                "firstName": "Joshua",'+
'                "lastName": "Lyman",'+
'                "company": "Yale University",'+
'                "title": "Deputy Chief of Staff",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/OYkurPQs5SslGyrP1f4f3CqbcjYxFwJu1gkfWI03JKf51VDN0-5S02oUfPHz7frc",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=OYkurPQs5SslGyrP1f4f3CqbcjYxFwJu1gkfWI03JKf51VDN0-5S02oUfPHz7frc&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T22:02:31.000+0000",'+
'            "paymentDate": "2020-09-25T22:02:31.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7290306,'+
'            "eventId": 242966,'+
'            "orderId": 4255708,'+
'            "created": "2020-09-25T22:02:30.000+0000",'+
'            "modified": "2020-09-29T20:18:10.576+0000",'+
'            "id": 7433450'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum"'+
'            },'+
'            "properties": {'+
'                "firstName": "Steven",'+
'                "lastName": "Mandelbaum",'+
'                "company": "University of Virginia",'+
'                "title": "Vice President",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=qIEC_Wb9tyn58cPi9Ta95JdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T22:18:46.000+0000",'+
'            "paymentDate": "2020-09-25T22:18:46.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7199619,'+
'            "eventId": 242966,'+
'            "orderId": 4255812,'+
'            "created": "2020-09-25T22:18:46.000+0000",'+
'            "modified": "2020-09-29T20:17:45.420+0000",'+
'            "id": 7433625'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins"'+
'            },'+
'            "properties": {'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins",'+
'                "company": "Dillon Community College",'+
'                "title": "Chief Business Officer",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/RKth8Sd-_dI2ckFrhJOBsZdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=RKth8Sd-_dI2ckFrhJOBsZdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T21:59:06.000+0000",'+
'            "paymentDate": "2020-09-25T21:59:06.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7202566,'+
'            "eventId": 242966,'+
'            "orderId": 4255683,'+
'            "created": "2020-09-25T21:59:06.000+0000",'+
'            "modified": "2020-09-29T20:18:17.585+0000",'+
'            "id": 7433410'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Delores",'+
'                "lastName": "Landingham"'+
'            },'+
'            "properties": {'+
'                "firstName": "Delores",'+
'                "lastName": "Landingham",'+
'                "company": "White House",'+
'                "title": "Secretary",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk0PaW2Lln31UOH2U9e-ydh9s93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk0PaW2Lln31UOH2U9e-ydh9s93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T21:52:17.000+0000",'+
'            "paymentDate": "2020-09-25T21:52:17.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7308407,'+
'            "eventId": 242966,'+
'            "orderId": 4255630,'+
'            "created": "2020-09-25T21:52:17.000+0000",'+
'            "modified": "2020-09-29T20:18:23.803+0000",'+
'            "id": 7433338'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "CJ",'+
'                "lastName": "Cregg"'+
'            },'+
'            "properties": {'+
'                "firstName": "CJ",'+
'                "lastName": "Cregg",'+
'                "company": "University of California Berkeley",'+
'                "title": "Press Secretary",'+
'                "sessionRegistration": [],'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk0c0u_p6SjJGn-ko_E88fJ5s93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk0c0u_p6SjJGn-ko_E88fJ5s93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-25T13:07:15.000+0000",'+
'            "paymentDate": "2020-09-25T13:07:15.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7297952,'+
'            "eventId": 242966,'+
'            "orderId": 4244431,'+
'            "created": "2020-09-25T13:07:14.000+0000",'+
'            "modified": "2020-09-29T20:18:32.094+0000",'+
'            "id": 7417713'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Donna",'+
'                "lastName": "Moss"'+
'            },'+
'            "properties": {'+
'                "firstName": "Donna",'+
'                "lastName": "Moss",'+
'                "company": "Wisconsin Community College",'+
'                "title": "Assistant",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/BT5KBcQGKEKCHz5nE-MWlZG9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=BT5KBcQGKEKCHz5nE-MWlZG9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-17T20:56:33.000+0000",'+
'            "paymentDate": "2020-09-17T20:56:33.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7190920,'+
'            "eventId": 242966,'+
'            "orderId": 4115193,'+
'            "created": "2020-09-17T20:56:33.000+0000",'+
'            "modified": "2020-09-29T20:19:23.063+0000",'+
'            "id": 7225119'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Anneke",'+
'                "lastName": "Herman"'+
'            },'+
'            "properties": {'+
'                "firstName": "Anneke",'+
'                "lastName": "Herman",'+
'                "company": "EAB",'+
'                "title": "Managing Director, Business Solutions",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/rTxfvm14zdtEeJ2m4CI0M5dhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=rTxfvm14zdtEeJ2m4CI0M5dhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-18T13:54:37.000+0000",'+
'            "paymentDate": "2020-09-18T13:54:37.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7199015,'+
'            "eventId": 242966,'+
'            "orderId": 4123394,'+
'            "created": "2020-09-18T13:54:37.000+0000",'+
'            "modified": "2020-09-29T20:19:17.318+0000",'+
'            "id": 7237881'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Jed",'+
'                "lastName": "Bartlet"'+
'            },'+
'            "properties": {'+
'                "firstName": "Jed",'+
'                "lastName": "Bartlet",'+
'                "company": "London School of Economics",'+
'                "title": "President",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/R3NwAUBOEUAoey0okGdjsZG9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=R3NwAUBOEUAoey0okGdjsZG9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-17T20:47:36.000+0000",'+
'            "paymentDate": "2020-09-17T20:47:36.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7186384,'+
'            "eventId": 242966,'+
'            "orderId": 4114999,'+
'            "created": "2020-09-17T20:47:35.000+0000",'+
'            "modified": "2020-09-29T20:19:28.687+0000",'+
'            "id": 7224805'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Test",'+
'                "lastName": "Press"'+
'            },'+
'            "properties": {'+
'                "firstName": "Test",'+
'                "lastName": "Press",'+
'                "company": "Test Newspaper",'+
'                "title": "Reporter",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/xByc_8s8Iz67rlYuUtltcqP-kALbIBp32InlWFbs4YjLOnFDAochATNfpjSbAruB",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=xByc_8s8Iz67rlYuUtltcqP-kALbIBp32InlWFbs4YjLOnFDAochATNfpjSbAruB&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-24T19:32:36.000+0000",'+
'            "paymentDate": "2020-09-24T19:32:36.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7281895,'+
'            "eventId": 242966,'+
'            "orderId": 4235546,'+
'            "created": "2020-09-24T19:32:36.000+0000",'+
'            "modified": "2020-09-29T20:19:03.239+0000",'+
'            "id": 7403920'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins"'+
'            },'+
'            "properties": {'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins",'+
'                "company": "Dillon Community College",'+
'                "title": "Chief Business Officer",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/RKth8Sd-_dI2ckFrhJOBsZdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=RKth8Sd-_dI2ckFrhJOBsZdhbR6nahABYSve9SsmStVs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-18T18:42:05.000+0000",'+
'            "paymentDate": "2020-09-18T18:42:05.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7202566,'+
'            "eventId": 242966,'+
'            "orderId": 4131444,'+
'            "created": "2020-09-18T18:42:04.000+0000",'+
'            "modified": "2020-09-29T20:19:10.874+0000",'+
'            "id": 7248858'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Ainsley",'+
'                "lastName": "Hayes"'+
'            },'+
'            "properties": {'+
'                "firstName": "Ainsley",'+
'                "lastName": "Hayes",'+
'                "company": "Smith College",'+
'                "title": "Associate Counsel",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/_g_KAjM1H1ap113lvGSgrPfjnyzg8Y-7kqLQsNins4BhamE3epKTq6praOFUSNrN",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=_g_KAjM1H1ap113lvGSgrPfjnyzg8Y-7kqLQsNins4BhamE3epKTq6praOFUSNrN&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-24T19:34:04.000+0000",'+
'            "paymentDate": "2020-09-24T19:34:04.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7290201,'+
'            "eventId": 242966,'+
'            "orderId": 4235576,'+
'            "created": "2020-09-24T19:34:04.000+0000",'+
'            "modified": "2020-09-29T20:18:39.842+0000",'+
'            "id": 7403958'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Jed",'+
'                "lastName": "Bartlet"'+
'            },'+
'            "properties": {'+
'                "firstName": "Jed",'+
'                "lastName": "Bartlet",'+
'                "test3": ['+
'                    "[Making the case for Navigate to senior leaders, Boosting Navigate Student adoption and utilization]"'+
'                ],'+
'                "attendeetype": "Guest",'+
'                "company": "London School of Economics",'+
'                "title": "President",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/R3NwAUBOEUAoey0okGdjsZG9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=R3NwAUBOEUAoey0okGdjsZG9t3zXD6UaeBCSWVh4eU2sBlaXgu_WIjqChCbnReUo&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:19:56.000+0000",'+
'            "paymentDate": "2020-09-29T14:19:56.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7186384,'+
'            "eventId": 242966,'+
'            "orderId": 4299532,'+
'            "created": "2020-09-29T14:19:56.000+0000",'+
'            "modified": "2020-09-29T20:15:51.311+0000",'+
'            "id": 7495348'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn"'+
'            },'+
'            "properties": {'+
'                "test_4": ['+
'                    "[[[Using Navigate in a virtual/hybrid environment]]]"'+
'                ],'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn",'+
'                "test3": ['+
'                    "[[[Closing equity gaps on campus]]]"'+
'                ],'+
'                "company": "Princeton University",'+
'                "title": "Deputy Communications Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk8OmImQcp6GYa8JJylm99HRs93O2o-Q1pfRWC6l1wHIJ",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk8OmImQcp6GYa8JJylm99HRs93O2o-Q1pfRWC6l1wHIJ&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:27:11.000+0000",'+
'            "paymentDate": "2020-09-29T14:27:11.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7304415,'+
'            "eventId": 242966,'+
'            "orderId": 4299728,'+
'            "created": "2020-09-29T14:27:11.000+0000",'+
'            "modified": "2020-09-29T20:15:45.525+0000",'+
'            "id": 7495639'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Delores",'+
'                "lastName": "Landingham"'+
'            },'+
'            "properties": {'+
'                "firstName": "Delores",'+
'                "lastName": "Landingham",'+
'                "test3": ['+
'                    "[Closing equity gaps on campus]"'+
'                ],'+
'                "attendeetype": "Guest / Non-Navigate Partner",'+
'                "company": "White House",'+
'                "title": "Secretary",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk0PaW2Lln31UOH2U9e-ydh-JT5bVv6ZR3X_l_outqDIS",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk0PaW2Lln31UOH2U9e-ydh-JT5bVv6ZR3X_l_outqDIS&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:31:28.000+0000",'+
'            "paymentDate": "2020-09-29T14:31:28.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7308407,'+
'            "eventId": 242966,'+
'            "orderId": 4299849,'+
'            "created": "2020-09-29T14:31:27.000+0000",'+
'            "modified": "2020-09-29T20:15:31.249+0000",'+
'            "id": 7495802'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Delores",'+
'                "lastName": "Landingham"'+
'            },'+
'            "properties": {'+
'                "firstName": "Delores",'+
'                "lastName": "Landingham",'+
'                "test3": ['+
'                    "[Closing equity gaps on campus, Engaging faculty and staff in using the Navigate platform]"'+
'                ],'+
'                "attendeetype": "Guest / Non-Navigate Partner",'+
'                "company": "White House",'+
'                "title": "Secretary",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk0PaW2Lln31UOH2U9e-ydh-JT5bVv6ZR3X_l_outqDIS",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk0PaW2Lln31UOH2U9e-ydh-JT5bVv6ZR3X_l_outqDIS&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:29:22.000+0000",'+
'            "paymentDate": "2020-09-29T14:29:22.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7308407,'+
'            "eventId": 242966,'+
'            "orderId": 4299791,'+
'            "created": "2020-09-29T14:29:21.000+0000",'+
'            "modified": "2020-09-29T20:15:38.661+0000",'+
'            "id": 7495736'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins"'+
'            },'+
'            "properties": {'+
'                "firstName": "Tim",'+
'                "lastName": "Riggins",'+
'                "test3": ['+
'                    "[Using Navigate in a virtual/hybrid environment]"'+
'                ],'+
'                "attendeetype": "Navigate Partner",'+
'                "company": "Dillon Community College",'+
'                "title": "Chief Business Officer",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/RKth8Sd-_dI2ckFrhJOBsZdhbR6nahABYSve9SsmStWJT5bVv6ZR3X_l_outqDIS",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=RKth8Sd-_dI2ckFrhJOBsZdhbR6nahABYSve9SsmStWJT5bVv6ZR3X_l_outqDIS&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Guest",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 151277,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:37:02.000+0000",'+
'            "paymentDate": "2020-09-29T14:37:02.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7202566,'+
'            "eventId": 242966,'+
'            "orderId": 4300082,'+
'            "created": "2020-09-29T14:37:01.000+0000",'+
'            "modified": "2020-09-29T20:15:11.315+0000",'+
'            "id": 7496138'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn"'+
'            },'+
'            "properties": {'+
'                "test_4": ['+
'                    "[[Using Navigate in a virtual/hybrid environment]]"'+
'                ],'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn",'+
'                "test3": ['+
'                    "[[Closing equity gaps on campus]]"'+
'                ],'+
'                "company": "Princeton University",'+
'                "title": "Deputy Communications Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk8OmImQcp6GYa8JJylm99HSJT5bVv6ZR3X_l_outqDIS",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk8OmImQcp6GYa8JJylm99HSJT5bVv6ZR3X_l_outqDIS&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:18:00.000+0000",'+
'            "paymentDate": "2020-09-29T14:18:00.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7304415,'+
'            "eventId": 242966,'+
'            "orderId": 4299474,'+
'            "created": "2020-09-29T14:17:59.000+0000",'+
'            "modified": "2020-09-29T20:15:59.200+0000",'+
'            "id": 7495247'+
'        },'+
'        {'+
'            "billingAddress": {'+
'                "email": "testuser2175436032@eab.com",'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn"'+
'            },'+
'            "properties": {'+
'                "test_4": ['+
'                    "[Using Navigate in a virtual/hybrid environment]"'+
'                ],'+
'                "firstName": "Sam",'+
'                "lastName": "Seaborn",'+
'                "test3": ['+
'                    "[Closing equity gaps on campus]"'+
'                ],'+
'                "company": "Princeton University",'+
'                "title": "Deputy Communications Director",'+
'                "email": "testuser2175436032@eab.com"'+
'            },'+
'            "manageRegistrationLink": "https://events.bizzabo.com/242966/settings/registration/fOK3dTmMbQ-6gK9nmmvvk8OmImQcp6GYa8JJylm99HSJT5bVv6ZR3X_l_outqDIS",'+
'            "magicLink": "https://events.bizzabo.com/auth/emailAssociatedLogin/verifyTokenAndRedirect?token=fOK3dTmMbQ-6gK9nmmvvk8OmImQcp6GYa8JJylm99HSJT5bVv6ZR3X_l_outqDIS&eventGroupId=34842&redirectUrl=https://events.bizzabo.com/242966/agenda",'+
'            "checkedin": false,'+
'            "virtualCheckin": false,'+
'            "ticketName": "Navigate Partner",'+
'            "price": 0,'+
'            "orderType": "manual",'+
'            "charge": 0,'+
'            "fees": 0,'+
'            "validity": "invalid",'+
'            "paymentStatus": "completed",'+
'            "currency": "USD",'+
'            "ticketId": 149835,'+
'            "invoice": false,'+
'            "status": "completed",'+
'            "registrationDate": "2020-09-29T14:16:17.000+0000",'+
'            "paymentDate": "2020-09-29T14:16:17.000+0000",'+
'            "paymentMethod": "creditCard",'+
'            "contactId": 7304415,'+
'            "eventId": 242966,'+
'            "orderId": 4299424,'+
'            "created": "2020-09-29T14:16:16.000+0000",'+
'            "modified": "2020-09-29T20:16:06.657+0000",'+
'            "id": 7495177'+
'        }'+
'    ],'+
'    "page": ['+
'        {'+
'        "size": 50,'+
'        "totalElements": 64,'+
'        "totalPages": 2,'+
'        "number": 0'+
'        }'+
'    ]'+
'}';
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}