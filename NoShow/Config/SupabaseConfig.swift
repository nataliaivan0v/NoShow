import Foundation
import Supabase

struct SupabaseConfig {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://dsjnjpolizapysxlcvuy.supabase.co")!,
        supabaseKey: "sb_publishable_h98vDVQ0v0_8LVFnCJOweQ_1kJxF456"
    )
}
