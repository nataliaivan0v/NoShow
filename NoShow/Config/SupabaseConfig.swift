import Foundation
import Supabase

struct SupabaseConfig {
    // TODO: setup supabase and update these values
    static let url = URL(string: "https://YOUR_PROJECT.supabase.co")!
    static let anonKey = "YOUR_ANON_KEY"

    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey
    )
}
