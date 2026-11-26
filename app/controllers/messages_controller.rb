# Agent replies and internal notes on a ticket.
class MessagesController < ApplicationController
  def create
    ticket = Ticket.find(params[:ticket_id])
    body = params.expect(message: [ :body ])[:body]

    if body.blank?
      redirect_to ticket, alert: "Reply can't be blank."
    elsif params[:note]
      ticket.add_internal_note!(user: Current.user, body: body)
      redirect_to ticket, notice: "Note added."
    elsif params[:close]
      message = ticket.add_agent_reply!(user: Current.user, body: body)
      TorqueLift::Analytics.ticket_replied(request: request, user_id: Current.user.id, message_id: "ticket-replied-#{message.id}", ticket_id: ticket.id)
      ticket.close_and_request_rating!
      redirect_to ticket, notice: "Reply sent and ticket closed."
    else
      message = ticket.add_agent_reply!(user: Current.user, body: body)
      TorqueLift::Analytics.ticket_replied(request: request, user_id: Current.user.id, message_id: "ticket-replied-#{message.id}", ticket_id: ticket.id)
      redirect_to ticket, notice: "Reply sent."
    end
  end
end
