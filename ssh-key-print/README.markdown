# SSH key print

Prints out the host's ssh keys in various formats. Idea is this can be shared with individuals to verify the server they are connecting to is indeed the correct one.

## Formats displayed

* `SSH` - This is how the fingerprint will be displayed when you do `ssh the_hostname`.
* `SHA1`, `SHA256` - Both of these just pass the base64 decoded key through the hash function. Useful if you're paranoid since all the `SSH` format is just an md5 hash with `:` every two characters
* `DNS` - Place this record in dns and then ssh clients can be told to verify the key that's in dns before connecting. It's provided in BIND format but should be able to adapt to your server type if different.

## SSH DNS records

While it's been around for a while, the use of `SSHFP` records in dns is pretty low. Partly because it's not really needed for most cases and also it can be subject to alterations until DNSSEC is implemented for your domain. Notably a case where this does make sense is when several servers share the same ssh key. For example github, who [does support SSHFP](https://help.github.com/articles/what-are-github-s-ssh-key-fingerprints).

Once you get those records in your dns you can then enable it by adding `VerifyHostKeyDNS yes` to your `~/.ssh/config`. For example:

    Host myserver.example.com
        User someone
        VerifyHostKeyDNS yes

You can also add this at the bottom of that file in a `Host *` section to make it default. The downside to this is there may be a delay initially connecting to servers that don't have this set. To verify this is all working you can run `ssh -v myserver.example.com` and you should see a line saying the fingerprint was found in dns.
