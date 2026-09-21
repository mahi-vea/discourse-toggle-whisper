import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const REGULAR = 1;
const WHISPER = 4;

export default class PostMenuFoldingButton extends Component {
  static hidden() {
    return true;
  }

  static shouldRender(args) {
    if (args.post.post_number === 1) {
      return false;
    }

    const currentUser = args.state.currentUser;
    if (!currentUser) {
      return false;
    }

    return settings.user_in_toggle_whisper_allowed_groups;
  }

  @service appEvents;

  get isWhisper() {
    return this.args.post.post_type === WHISPER;
  }

  get title() {
    return themePrefix(
      this.isWhisper
        ? "toggle_button_title.regular"
        : "toggle_button_title.whisper"
    );
  }

  get icon() {
    return this.isWhisper ? "far-eye" : "far-eye-slash";
  }

  @action
  toggleWhisper() {
    const model = this.args.post;
    const newType = this.isWhisper ? REGULAR : WHISPER;
    const endpoint = settings.toggle_whisper_endpoint;

    if (endpoint) {
      // Non-staff members cannot use Discourse's own post_type route
      // (PostGuardian#can_change_post_type? is staff-only), so delegate the
      // change to a backend that holds an API key.
      ajax(endpoint, {
        type: "POST",
        contentType: "application/json",
        dataType: "json",
        data: JSON.stringify({
          post_id: model.id,
          post_type: newType,
          username: this.args.state.currentUser?.username,
        }),
      })
        .then(() => model.set("post_type", newType))
        .catch(popupAjaxError);
      return;
    }

    ajax(`/posts/${model.id}/post_type`, {
      type: "PUT",
      data: {
        post_type: newType,
      },
    }).catch(popupAjaxError);
  }

  <template>
    <DButton
      class="toggle-whisper-btn"
      ...attributes
      @action={{this.toggleWhisper}}
      @icon={{this.icon}}
      @title={{this.title}}
    />
  </template>
}
