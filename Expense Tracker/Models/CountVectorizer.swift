//
//  CountVectorizer.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2024-02-13.
//

import Foundation
import NaturalLanguage

struct CountVectorizer {
    let vocabulary: [String: Int]
    let tokenizer: NLTokenizer
    
    init(vocabulary: [String : Int], tokenizer: NLTokenizer) {
        self.vocabulary = vocabulary
        self.tokenizer = tokenizer
    }
    
    func vectorize(text: String) -> [Double] {
        var vector = [Double](repeating: 0.0, count: vocabulary.count)
        
        tokenizer.string = text
        let tokens = tokenizer.tokens(for: text.startIndex..<text.endIndex)
        
        for token in tokens {
            let tokenText = String(text[token])
            if let index = vocabulary[tokenText.lowercased()] {
                vector[index] += 1.0
            }
        }
        
        return vector
    }
    
    static func preprocessText(text: String) -> String {
        var transactionText = text.replacingOccurrences(of: "\\d+", with: "NUM", options: .regularExpression)
        transactionText = transactionText.replacingOccurrences(of: "(?<=\\w)[^a-zA-Z\\s\\.\\@](?=\\w)", with: " ", options: .regularExpression)
        transactionText = JMUnidecode.unidecode(transactionText)
        return transactionText
    }
    
    static func getVocabulary() -> [String: Int] {
        return ["yalla": 283, "habibi": 96, "kun": 137, "swish": 247, "trafikverket": 260, "fa": 69, "vy": 275, "buss": 36, "ching": 44, "palace": 185, "taco": 248, "bar": 24, "kompass": 134, "ab": 0, "storstockholm": 235, "tap": 250, "malpensa": 153, "ge": 87, "kas": 126, "va": 267, "sttrafik": 237, "skickad": 226, "num": 175, "uber": 263, "trip": 261, "help": 102, "apna": 10, "bazar": 26, "kvill": 139, "verfa": 271, "ring": 206, "internet": 118, "regionservice": 201, "pa": 184, "omio": 181, "skmt": 227, "hellofresh": 101, "parkering": 186, "teb": 252, "easypark": 62, "bestseller": 30, "agape": 2, "premium": 195, "su": 238, "cafe": 37, "husaren": 112, "kinto": 131, "share": 222, "swed": 244, "hemka": 103, "ga": 85, "teborg": 253, "foodora": 75, "klarna": 133, "testmotta": 256, "volvo": 274, "demand": 57, "telenor": 254, "waffles": 276, "pris": 199, "nyckelkund": 178, "dahls": 54, "bageri": 22, "abdul": 1, "frisorsalo": 80, "jysk": 123, "backaplan": 20, "ding": 58, "normal": 173, "lidl": 144, "gotebor": 92, "centralens": 40, "toale": 258, "kvilletorgets": 141, "tr": 259, "roberts": 208, "coffee": 48, "zettle_": 285, "bangkok": 23, "universeum": 266, "mottagen": 164, "skandia": 223, "willys": 280, "hemma": 105, "kvi": 138, "wieselgre": 279, "saigon": 215, "city": 46, "flixbus": 72, "com": 49, "ka": 124, "rkortsavgifter": 207, "apoteket": 12, "backapl": 19, "netflix": 169, "hedvig": 100, "numg": 176, "maritiman": 156, "se": 220, "vapiano": 268, "stra": 236, "ha": 95, "ryanairnumgi": 211, "bolt": 33, "eu": 67, "hallon": 98, "lilla": 145, "cafeet": 38, "pps": 194, "foods": 76, "google": 91, "youtube": 284, "mevlanagoteborg": 160, "ceviche": 41, "prev": 198, "mth": 165, "saved": 219, "wise": 281, "picadeli": 188, "kd": 127, "apotek": 11, "wallenstam": 277, "max": 157, "burgers": 35, "espresso": 66, "otter": 183, "ai": 3, "chicken": 43, "hut": 113, "rest": 203, "autoservizi": 16, "loca": 149, "biltema": 32, "sweden": 246, "ikorkort": 116, "forex": 77, "nordstan": 172, "pressbyr": 196, "rent": 202, "july": 121, "wei": 278, "asian": 14, "ea": 61, "moon": 163, "thai": 257, "kitche": 132, "kafe": 125, "alk": 7, "ch": 42, "alice": 6, "pizza": 190, "ica": 114, "nara": 168, "kvilleb": 140, "coop": 52, "lundby": 150, "sannegardens": 217, "keb": 128, "subway": 239, "goteborg": 93, "bauhaus": 25, "var": 269, "akademibokhande": 5, "convini": 51, "house": 111, "hive": 106, "piz": 189, "glade": 89, "johans": 120, "god": 90, "condeco": 50, "fredsgat": 78, "cj": 47, "liseberg": 148, "entre": 65, "eats": 63, "socker": 230, "sucker": 240, "flygbussarna": 73, "hammarhallen": 99, "sota": 231, "ber": 28, "express": 68, "food": 74, "dufrital": 60, "mxp": 167, "june": 122, "turkisk": 262, "sultan": 241, "hemkop": 104, "yaki": 282, "da": 53, "filmstaden": 71, "tb": 251, "orebr": 182, "starbucks": 233, "hnum": 109, "saudi": 218, "french": 79, "sultanzade": 242, "power": 193, "fuelstation": 84, "nyttig": 179, "snabbmat": 229, "haga": 97, "sknum": 228, "stora": 234, "backa": 17, "ec": 64, "indian": 117, "hous": 110, "gromart": 94, "srl": 232, "circle": 45, "vestra": 272, "gekas": 88, "restaurang": 205, "landvetter": 143, "kortt": 136, "salgren": 216, "ukvi": 265, "play": 191, "apps": 13, "ryanairnumnw": 213, "teleperformance": 255, "dollarstore": 59, "payment": 187, "alkemisten": 8, "lindh": 147, "ryanairnumahrvxj": 209, "playstation": 192, "netw": 170, "region": 200, "skane": 224, "skay": 225, "ryanairnumty": 214, "centrale": 39, "mnum": 162, "autogrill": 15, "kicks": 130, "backap": 18, "isabelle": 119, "restaur": 204, "berg": 29, "amzn": 9, "mktp": 161, "la": 142, "supermark": 243, "hjartat": 107, "hm": 108, "senum": 221, "tandklinik": 249, "fuelstati": 83, "burger": 34, "mansion": 154, "ryanairnumew": 210, "mcd": 158, "numgbg": 177, "ryanairnumkp": 212, "mal": 151, "nner": 171, "deg": 55, "uk": 264, "visa": 273, "ftc": 82, "vastra": 270, "frolu": 81, "ikea": 115, "backebol": 21, "ki": 129, "betaltoalett": 31, "kooperativet": 135, "lin": 146, "delsjogrillen": 56, "benne": 27, "med": 159, "faerja": 70, "muslim": 166, "aid": 4, "swede": 245, "pressbyran": 197, "norra": 174, "march": 155, "olearys": 180, "gateau": 86, "malmo": 152]
    }
}
