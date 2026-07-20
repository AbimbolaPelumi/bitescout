import CoreLocation
import Foundation

enum MockRestaurants {
    static let all: [Restaurant] = {
        let details: [(Int, String, Double, Int, Int, [String], String, String, String, Double, Double)] = [
            (1, "Ocean Basket Victoria Island", 4.5, 5_200, 2, ["Seafood", "Mediterranean"], "35, Akin Adesola Street, Victoria Island, Lagos, NG", "Victoria Island, Lagos", "OceanBasketPhoto", 6.4280, 3.4210),
            (2, "Nok by Alara", 4.8, 2_300, 3, ["Nigerian", "Modern"], "21, Awolowo Road, Ikoyi, Lagos, Nigeria", "Victoria Island, Lagos", "NokPhoto", 6.4310, 3.4236),
            (3, "Bungalow Restaurant", 4.2, 1_800, 2, ["Continental", "Casual"], "22, Obafemi Awolowo Way, Ikeja, Lagos, Nigeria", "Victoria Island, Lagos", "BungalowPhoto", 6.4268, 3.4184),
            (4, "The Yellow Chilli", 4.3, 3_500, 2, ["Nigerian", "Upscale"], "144, Akin Adesola St, Victoria Island, Lagos, Nigeria", "Victoria Island, Lagos", "YellowChilliPhoto", 6.4296, 3.4259),
            (5, "Cactus Restaurant", 4.0, 4_000, 2, ["International", "Family-friendly"], "1A, Ozumba Mbadiwe Avenue, Victoria Island, Lagos, Nigeria", "Victoria Island, Lagos", "CactusPhoto", 6.4253, 3.4198),
            (6, "Terra Kulture", 4.6, 1_900, 2, ["Nigerian", "Arts café"], "1376, Tiamiyu Savage Street, Victoria Island, Lagos", "Victoria Island, Lagos", "RestaurantCoral", 6.4262, 3.4245),
            (7, "Z Kitchen", 4.7, 980, 3, ["Fine dining", "European"], "19, Saka Tinubu Street, Victoria Island, Lagos", "Victoria Island, Lagos", "RestaurantLeaf", 6.4331, 3.4205),
            (8, "Craft Gourmet", 4.4, 1_200, 3, ["Brunch", "European"], "Mega Plaza, Idowu Martins Street, Lagos", "Victoria Island, Lagos", "RestaurantSand", 6.4324, 3.4222),
            (9, "Shiro Lagos", 4.6, 2_800, 4, ["Asian", "Fine dining"], "Block XVI, Water Corporation Drive, Lagos", "Victoria Island, Lagos", "RestaurantGold", 6.4318, 3.4282),
            (10, "Café Neo", 4.1, 760, 1, ["Café", "Bakery"], "6, Agoro Odiyan Street, Victoria Island, Lagos", "Victoria Island, Lagos", "RestaurantSage", 6.4287, 3.4268),
            (11, "RSVP Lagos", 4.5, 2_100, 3, ["American", "Bar"], "9, Eletu Ogabi Street, Victoria Island, Lagos", "Victoria Island, Lagos", "RestaurantCoral", 6.4258, 3.4237),
            (12, "The House", 4.4, 1_400, 3, ["International", "Lounge"], "4, A.J. Marinho Drive, Victoria Island, Lagos", "Victoria Island, Lagos", "RestaurantLeaf", 6.4249, 3.4260),
            (13, "Salma's", 4.6, 920, 3, ["Lebanese", "Mediterranean"], "20, Akin Adesola Street, Victoria Island, Lagos", "Victoria Island, Lagos", "RestaurantSand", 6.4266, 3.4290),
            (14, "The Delborough Grill", 4.8, 430, 4, ["Steakhouse", "Fine dining"], "Plot 1501, Bishop Aboyade Cole Street, Lagos", "Victoria Island, Lagos", "RestaurantGold", 6.4289, 3.4252),
            (15, "La Taverna", 4.5, 1_100, 2, ["Italian", "Chilean"], "48, Balarabe Musa Crescent, Victoria Island, Lagos", "Victoria Island, Lagos", "RestaurantSage", 6.4218, 3.4284),
            (16, "Samantha's Bistro", 4.3, 840, 2, ["Bistro", "Brunch"], "2, Olawale Daodu Road, Victoria Island, Lagos", "Victoria Island, Lagos", "RestaurantCoral", 6.4284, 3.4148),
            (17, "Eric Kayser", 4.4, 1_600, 2, ["Bakery", "Café"], "864, Bishop Aboyade Cole Street, Lagos", "Victoria Island, Lagos", "RestaurantLeaf", 6.4336, 3.4165),
            (18, "Kaly Restaurant", 4.7, 620, 3, ["Mediterranean", "Buffét"], "1, Karimu Kotun Street, Victoria Island, Lagos", "Victoria Island, Lagos", "RestaurantSand", 6.4302, 3.4190),
            (19, "Maison Fahrenheit", 4.2, 1_300, 3, ["Rooftop", "Bar"], "80, Adetokunbo Ademola Street, Lagos", "Victoria Island, Lagos", "RestaurantGold", 6.4238, 3.4157),
            (20, "Hard Rock Café Lagos", 4.5, 6_100, 3, ["American", "Fast food"], "Landmark Village, Water Corporation Road, Lagos", "Victoria Island, Lagos", "RestaurantSage", 6.4270, 3.4175)
        ]
        return details.map { item in
            Restaurant(id: UUID(), pinNumber: item.0, name: item.1, rating: item.2,
                       reviewCount: item.3, priceLevel: item.4, cuisines: item.5,
                       fullAddress: item.6, shortAddress: item.7, imageName: item.8,
                       coordinate: .init(latitude: item.9, longitude: item.10), isBookmarked: false)
        }
    }()
}
